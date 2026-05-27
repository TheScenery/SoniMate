# MicMonitor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** macOS 状态栏应用，实时监听麦克风输入音量并以动态波形图标提示社交适宜度。

**Architecture:** 纯 Swift + AppKit 实现，使用 AVAudioEngine 捕获麦克风音频、Core Graphics 绘制波形图标、NSStatusItem 展示在状态栏。基于 SPM 构建，辅以 Makefile 生成 .app 包。

**Tech Stack:** Swift 6, AppKit, AVFoundation (AVAudioEngine), Core Graphics, SPM

---

### Task 1: 项目脚手架搭建

**Files:**
- Create: `Package.swift`
- Create: `Info.plist`
- Create: `Makefile`
- Create: `Sources/MicMonitor/main.swift`
- Create: `.gitignore`

- [ ] **Step 1: 创建 Package.swift**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MicMonitor",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MicMonitor",
            dependencies: [],
            path: "Sources/MicMonitor",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Info.plist"])
            ]
        ),
        .testTarget(
            name: "MicMonitorTests",
            dependencies: ["MicMonitor"],
            path: "Tests/MicMonitorTests"
        )
    ]
)
```

- [ ] **Step 2: 创建 Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>MicMonitor needs microphone access to monitor your speaking volume and help you maintain a polite conversation level.</string>
    <key>CFBundleName</key>
    <string>MicMonitor</string>
    <key>CFBundleDisplayName</key>
    <string>MicMonitor</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.micmonitor</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
```

- [ ] **Step 3: 创建 Makefile**

```makefile
APP_NAME = MicMonitor
BUILD_DIR = .build
APP_BUNDLE = $(APP_NAME).app

.PHONY: all build bundle run clean

all: bundle

build:
	swift build -c release

bundle: build
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	touch $(APP_BUNDLE)

run: bundle
	open $(APP_BUNDLE)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(APP_BUNDLE)
```

- [ ] **Step 4: 创建 main.swift**

```swift
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

- [ ] **Step 5: 创建 .gitignore**

```
.build/
*.app/
.DS_Store
.superpowers/
```

- [ ] **Step 6: 创建 Tests 目录并验证构建**

Run:
```bash
mkdir -p Tests/MicMonitorTests
swift build
```

Expected: Build succeeds with "Build complete!" (main.swift 引用了尚未定义的 AppDelegate，但 SPM 不会阻止编译 — 实际会因缺少符号而链接失败。后续 Task 会补全。)

---

### Task 2: VolumeLevel 枚举

**Files:**
- Create: `Sources/MicMonitor/VolumeLevel.swift`
- Create: `Tests/MicMonitorTests/VolumeLevelTests.swift`

- [ ] **Step 1: 编写 VolumeLevel.swift**

```swift
import AppKit

enum VolumeLevel: Int, CaseIterable {
    case quiet = 0
    case moderate = 1
    case loud = 2

    static let quietThreshold: Float = 0.3
    static let moderateThreshold: Float = 0.7

    static func from(normalizedValue: Float) -> VolumeLevel {
        switch normalizedValue {
        case ..<quietThreshold:
            return .quiet
        case quietThreshold..<moderateThreshold:
            return .moderate
        default:
            return .loud
        }
    }

    var color: NSColor {
        switch self {
        case .quiet:   return NSColor(red: 0.13, green: 0.77, blue: 0.37, alpha: 1.0)
        case .moderate: return NSColor(red: 0.92, green: 0.70, blue: 0.07, alpha: 1.0)
        case .loud:    return NSColor(red: 0.94, green: 0.23, blue: 0.18, alpha: 1.0)
        }
    }

    var label: String {
        switch self {
        case .quiet:    return "quiet"
        case .moderate: return "moderate"
        case .loud:     return "loud"
        }
    }
}
```

- [ ] **Step 2: 编写 VolumeLevelTests.swift**

```swift
import Testing
@testable import MicMonitor

struct VolumeLevelTests {

    @Test func quietThreshold() {
        #expect(VolumeLevel.from(normalizedValue: 0.0) == .quiet)
        #expect(VolumeLevel.from(normalizedValue: 0.1) == .quiet)
        #expect(VolumeLevel.from(normalizedValue: 0.29) == .quiet)
    }

    @Test func moderateThreshold() {
        #expect(VolumeLevel.from(normalizedValue: 0.3) == .moderate)
        #expect(VolumeLevel.from(normalizedValue: 0.5) == .moderate)
        #expect(VolumeLevel.from(normalizedValue: 0.69) == .moderate)
    }

    @Test func loudThreshold() {
        #expect(VolumeLevel.from(normalizedValue: 0.7) == .loud)
        #expect(VolumeLevel.from(normalizedValue: 0.9) == .loud)
        #expect(VolumeLevel.from(normalizedValue: 1.0) == .loud)
    }

    @Test func boundaryValues() {
        #expect(VolumeLevel.from(normalizedValue: 0.3) == .moderate)
        #expect(VolumeLevel.from(normalizedValue: 0.7) == .loud)
    }

    @Test func allCasesOrder() {
        let cases = VolumeLevel.allCases
        #expect(cases == [.quiet, .moderate, .loud])
    }
}
```

- [ ] **Step 3: 运行测试**

Run:
```bash
swift test --filter VolumeLevelTests
```

Expected: All tests PASS

- [ ] **Step 4: 提交**

```bash
git init
git add -A
git commit -m "feat: project scaffold and VolumeLevel enum"
```

---

### Task 3: IconGenerator

**Files:**
- Create: `Sources/MicMonitor/IconGenerator.swift`

- [ ] **Step 1: 编写 IconGenerator.swift**

```swift
import AppKit
import CoreGraphics

struct IconGenerator {

    static let iconSize = NSSize(width: 20, height: 20)

    static func icon(for level: VolumeLevel) -> NSImage {
        let image = NSImage(size: iconSize, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            self.drawWaveform(in: rect, level: level, context: ctx)
            return true
        }
        image.isTemplate = false
        return image
    }

    static func disabledIcon() -> NSImage {
        let image = NSImage(size: iconSize, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.setFillColor(NSColor.gray.withAlphaComponent(0.4).cgColor)
            let micRect = CGRect(
                x: rect.midX - 4, y: rect.midY - 6,
                width: 8, height: 14
            )
            ctx.fillEllipse(in: CGRect(x: rect.midX - 4, y: rect.midY - 6, width: 8, height: 6))
            ctx.fill(CGRect(x: rect.midX - 2, y: rect.midY - 4, width: 4, height: 10))
            ctx.setLineWidth(1.5)
            ctx.setStrokeColor(NSColor.gray.withAlphaComponent(0.4).cgColor)
            ctx.move(to: CGPoint(x: rect.midX, y: rect.midY + 6))
            ctx.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 10))
            ctx.strokePath()
            return true
        }
        image.isTemplate = false
        return image
    }

    private static func drawWaveform(in rect: CGRect, level: VolumeLevel, context ctx: CGContext) {
        let barCount = 4
        let barWidth: CGFloat = 2.5
        let spacing: CGFloat = 2.0
        let totalWidth = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * spacing
        let startX = rect.midX - totalWidth / 2

        let maxHeight: CGFloat
        switch level {
        case .quiet:    maxHeight = 6
        case .moderate: maxHeight = 11
        case .loud:     maxHeight = 16
        }

        ctx.setFillColor(level.color.cgColor)

        for i in 0..<barCount {
            let barHeight: CGFloat
            switch level {
            case .quiet:
                barHeight = maxHeight * [0.4, 0.6, 0.8, 0.5][i]
            case .moderate:
                barHeight = maxHeight * [0.5, 0.7, 1.0, 0.6][i]
            case .loud:
                barHeight = maxHeight * [0.6, 0.8, 1.0, 0.7][i]
            }

            let x = startX + CGFloat(i) * (barWidth + spacing)
            let y = rect.midY - barHeight / 2
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = CGPath(roundedRect: barRect, cornerWidth: 1, cornerHeight: 1, transform: nil)
            ctx.addPath(path)
            ctx.fillPath()
        }
    }
}
```

No tests for IconGenerator (requires NSImage rendering, impractical to automate — verified visually during build).

- [ ] **Step 2: 提交**

```bash
git add -A && git commit -m "feat: IconGenerator with waveform drawing"
```

---

### Task 4: AudioMonitor

**Files:**
- Create: `Sources/MicMonitor/AudioMonitor.swift`
- Create: `Tests/MicMonitorTests/AudioMonitorTests.swift`

- [ ] **Step 1: 编写 AudioMonitor.swift**

```swift
import AVFoundation
import AppKit

class AudioMonitor {

    var onVolumeChange: ((VolumeLevel, Float) -> Void)?

    private let engine = AVAudioEngine()
    private var isRunning = false

    var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    func start() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            requestPermission { [weak self] granted in
                if granted { self?.startCapture() }
            }
        case .authorized:
            startCapture()
        case .denied, .restricted:
            onVolumeChange?(.quiet, 0)
        @unknown default:
            onVolumeChange?(.quiet, 0)
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        isRunning = false
    }

    private func requestPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    private func startCapture() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        do {
            try engine.start()
            isRunning = true
        } catch {
            onVolumeChange?(.quiet, 0)
        }
    }

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }
        let rms = sqrt(sum / Float(frameLength))
        let normalized = Self.normalizeVolume(rms)

        let level = VolumeLevel.from(normalizedValue: normalized)
        onVolumeChange?(level, normalized)
    }

    static func normalizeVolume(_ rms: Float) -> Float {
        let minDb: Float = -60
        let maxDb: Float = 0

        let db = rms > 0 ? 20 * log10(rms) : minDb
        let clamped = max(minDb, min(maxDb, db))
        return (clamped - minDb) / (maxDb - minDb)
    }

    static func computeRMS(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }
        return sqrt(sum / Float(frameLength))
    }
}
```

- [ ] **Step 2: 编写 AudioMonitorTests.swift**

```swift
import Testing
import AVFoundation
@testable import MicMonitor

struct AudioMonitorTests {

    @Test func normalizeSilence() {
        let normalized = AudioMonitor.normalizeVolume(0)
        #expect(normalized == 0)
    }

    @Test func normalizeLoudSignal() {
        let normalized = AudioMonitor.normalizeVolume(1.0)
        #expect(abs(normalized - 1.0) < 0.01)
    }

    @Test func normalizeMidSignal() {
        // rms = 0.1 -> 20*log10(0.1) = -20dB -> (-20 - (-60)) / 60 = 40/60 ≈ 0.667
        let normalized = AudioMonitor.normalizeVolume(0.1)
        #expect(abs(normalized - 0.667) < 0.01)
    }

    @Test func computeRMSZeroBuffer() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512)!
        buffer.frameLength = 512
        let data = buffer.floatChannelData![0]
        data.initialize(repeating: 0, count: 512)

        let rms = AudioMonitor.computeRMS(from: buffer)
        #expect(rms == 0)
    }

    @Test func computeRMSConstantBuffer() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512)!
        buffer.frameLength = 512
        let data = buffer.floatChannelData![0]
        data.initialize(repeating: 0.5, count: 512)

        let rms = AudioMonitor.computeRMS(from: buffer)
        #expect(abs(rms - 0.5) < 0.001)
    }
}
```

- [ ] **Step 3: 运行测试**

Run:
```bash
swift test --filter AudioMonitorTests
```

Expected: All tests PASS

- [ ] **Step 4: 提交**

```bash
git add -A && git commit -m "feat: AudioMonitor with RMS calculation and volume normalization"
```

---

### Task 5: StatusBarController

**Files:**
- Create: `Sources/MicMonitor/StatusBarController.swift`

- [ ] **Step 1: 编写 StatusBarController.swift**

```swift
import AppKit

class StatusBarController {

    private let statusItem: NSStatusItem
    private var currentLevel: VolumeLevel = .quiet

    init() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.image = IconGenerator.disabledIcon()

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "MicMonitor v1.0",
            action: nil,
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        statusItem.menu = menu
    }

    func updateVolumeLevel(_ level: VolumeLevel, _: Float) {
        guard currentLevel != level else { return }
        currentLevel = level
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.image = IconGenerator.icon(for: level)
            self?.statusItem.button?.toolTip = self?.tooltip(for: level)
        }
    }

    func showDisabled() {
        statusItem.button?.image = IconGenerator.disabledIcon()
        statusItem.button?.toolTip = "MicMonitor: No microphone access"
    }

    private func tooltip(for level: VolumeLevel) -> String {
        switch level {
        case .quiet:    return "Volume: Quiet — you can speak up"
        case .moderate: return "Volume: Moderate — polite conversation level"
        case .loud:     return "Volume: Loud — please lower your voice"
        }
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add -A && git commit -m "feat: StatusBarController with menu and icon updates"
```

---

### Task 6: AppDelegate + main.swift 整合

**Files:**
- Create: `Sources/MicMonitor/AppDelegate.swift`
- Modify: `Sources/MicMonitor/main.swift`（已在 Task 1 创建，确认即可）

- [ ] **Step 1: 编写 AppDelegate.swift**

```swift
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?
    private var audioMonitor: AudioMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        audioMonitor = AudioMonitor()

        audioMonitor?.onVolumeChange = { [weak self] level, value in
            self?.statusBarController?.updateVolumeLevel(level, value)
        }

        if audioMonitor?.isAuthorized == false {
            statusBarController?.showDisabled()
        }

        audioMonitor?.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        audioMonitor?.stop()
    }
}
```

- [ ] **Step 2: 构建并验证**

Run:
```bash
make build
```

Expected: Build succeeds. If it fails due to missing `AVAudioSession` import, use `AVCaptureDevice` for permission check instead (see note below).

- [ ] **Step 3: 提交**

```bash
git add -A && git commit -m "feat: AppDelegate integrating all modules"
```

---

### Task 7: 构建 .app bundle 并验证

- [ ] **Step 1: 完整构建**

Run:
```bash
make clean && make bundle
```

Expected: `MicMonitor.app/Contents/MacOS/MicMonitor` 存在且可执行。

- [ ] **Step 2: 验证 bundle 结构**

Run:
```bash
ls -la MicMonitor.app/Contents/
ls -la MicMonitor.app/Contents/MacOS/
```

Expected: Info.plist 和可执行文件存在。

- [ ] **Step 3: 确认 Info.plist 包含 LSUIElement**

Run:
```bash
plutil -p MicMonitor.app/Contents/Info.plist | grep LSUIElement
```

Expected: `"LSUIElement" => 1` (或 `true`)

- [ ] **Step 4: 提交最终版本**

```bash
git add -A && git commit -m "chore: final build configuration"
```

---

### 验证清单

| 检查项 | 方式 |
|--------|------|
| VolumeLevel 阈值逻辑 | `swift test --filter VolumeLevelTests` 全部通过 |
| RMS 计算逻辑 | `swift test --filter AudioMonitorTests` 全部通过 |
| 构建成功 | `make build` 无错误 |
| .app bundle 生成 | `make bundle` 创建 MicMonitor.app |
| Info.plist LSUIElement | plutil 确认值为 true |
| 麦克风权限弹窗 | 手动启动后出现系统权限请求 |
| 状态栏图标显示 | 手动启动后在 menu bar 可见 |
| 音量变化图标切换 | 对麦克风说话，图标随音量变化 |
| 右键菜单退出 | 右键 → Quit 正常退出 |
