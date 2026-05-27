import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
