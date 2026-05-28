import AppKit
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?
    private var audioMonitor: AudioMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        audioMonitor = AudioMonitor()

        audioMonitor?.onVolumeChange = { [weak self] level, _ in
            self?.statusBarController?.updateVolumeLevel(level)
        }

        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .denied || status == .restricted {
            statusBarController?.showDisabled()
        }

        audioMonitor?.start()

        if status == .notDetermined {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        audioMonitor?.stop()
        statusBarController?.removeStatusItem()
    }
}
