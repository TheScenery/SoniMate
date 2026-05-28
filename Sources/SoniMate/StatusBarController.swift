import AppKit

class StatusBarController {

    private let statusItem: NSStatusItem
    private var currentLevel: VolumeLevel?
    private var pendingLevel: VolumeLevel?
    private var holdTimer: Timer?
    private let holdDuration: TimeInterval = 3.0

    init() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.image = IconGenerator.disabledIcon()

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "SoniMate v1.2.0",
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

    func updateVolumeLevel(_ level: VolumeLevel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if level == .loud {
                self.holdTimer?.invalidate()
                self.holdTimer = nil
                self.pendingLevel = nil
                self.applyLevel(level)
            } else if self.currentLevel == .loud {
                self.pendingLevel = level
                if self.holdTimer == nil {
                    self.holdTimer = Timer.scheduledTimer(withTimeInterval: self.holdDuration, repeats: false) { [weak self] _ in
                        guard let self else { return }
                        if let pending = self.pendingLevel {
                            self.applyLevel(pending)
                        }
                        self.holdTimer = nil
                        self.pendingLevel = nil
                    }
                }
            } else {
                self.applyLevel(level)
            }
        }
    }

    func removeStatusItem() {
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    func showDisabled() {
        currentLevel = nil
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.statusItem.button?.image = IconGenerator.disabledIcon()
            self.statusItem.button?.toolTip = "SoniMate: No microphone access"

            if let menu = self.statusItem.menu {
                let items = menu.items
                let hasSettings = items.contains { $0.action == #selector(self.openPrivacySettings) }
                if !hasSettings {
                    let settingsItem = NSMenuItem(
                        title: "Grant Microphone Access...",
                        action: #selector(self.openPrivacySettings),
                        keyEquivalent: ""
                    )
                    settingsItem.target = self
                    menu.insertItem(settingsItem, at: 1)
                    menu.insertItem(NSMenuItem.separator(), at: 2)
                }
            }
        }
    }

    @objc private func openPrivacySettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
    }

    private func applyLevel(_ level: VolumeLevel) {
        guard currentLevel != level else { return }
        currentLevel = level
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.image = IconGenerator.icon(for: level)
            self?.statusItem.button?.toolTip = self?.tooltip(for: level)
        }
    }

    private func tooltip(for level: VolumeLevel) -> String {
        switch level {
        case .quiet:    return "Volume: Quiet — you can speak up"
        case .moderate: return "Volume: Moderate — polite conversation level"
        case .loud:     return "Volume: Loud — please lower your voice"
        }
    }
}
