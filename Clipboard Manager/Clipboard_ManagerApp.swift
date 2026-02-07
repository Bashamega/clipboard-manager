import SwiftUI
import ApplicationServices
import Combine

// MARK: - Main App Entry
@main
struct ClipboardMenuBarApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AccessibilityStatusView() // Or your ClipboardWindowView
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Use the shared singleton instance
    private let copyListener = CopyListener.shared
    private var menuController: MenuController?
    private var permissionCheckTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize menu controller with the shared listener
        menuController = MenuController(copyListener: copyListener)
        
        // Start clipboard monitoring if accessibility permission granted
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
        // Clean up timers
        permissionCheckTimer?.invalidate()
        copyListener.stop()
    }
}

// MARK: - SwiftUI Clipboard Listener Wrapper
final class CopyListenerWrapper: ObservableObject {

    // Published property for SwiftUI to observe
    @Published var history: [JSONFileManager.Clip] = []

    private let listener: CopyListener

    init(listener: CopyListener = CopyListener.shared) {
        self.listener = listener

        // Sync clipboard history whenever it changes
        listener.addObserver { [weak self] in
            DispatchQueue.main.async {
                self?.history = listener.getHistory()
            }
        }

        // Initialize the published history
        self.history = listener.getHistory()

        // Start monitoring if not already started
        listener.start()
    }
}
