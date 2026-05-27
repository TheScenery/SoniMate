import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?
    private var audioMonitor: AudioMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        audioMonitor = AudioMonitor()

        audioMonitor?.onVolumeChange = { [weak self] level, _ in
            self?.statusBarController?.updateVolumeLevel(level)
        }

        if audioMonitor?.isAuthorized == false {
            statusBarController?.showDisabled()
        }

        if audioMonitor?.isAuthorized == true {
            audioMonitor?.start()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        audioMonitor?.stop()
        statusBarController?.removeStatusItem()
    }
}
