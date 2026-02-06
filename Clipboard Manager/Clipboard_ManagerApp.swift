import SwiftUI
import ApplicationServices

@main
struct ClipboardMenuBarApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AccessibilityStatusView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private let copyListener = CopyListener()
    private var menuController: MenuController?
    private var permissionCheckTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize menu controller
        menuController = MenuController(copyListener: copyListener)
        
        // Start the app
        requestAccessibilityIfNeeded()
    }
    
    private func requestAccessibilityIfNeeded() {
        if Accessibility.checkPermission() {
            copyListener.start()
        } else {
            Accessibility.promptPermission()

            // Poll until permission granted
            permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if Accessibility.checkPermission() {
                    timer.invalidate()
                    self?.permissionCheckTimer = nil
                    self?.copyListener.start()
                }
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up
        permissionCheckTimer?.invalidate()
        copyListener.stop()
    }
}
