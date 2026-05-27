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
