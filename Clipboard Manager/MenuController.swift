//
//  MenuController.swift
//  Clipboard Manager
//
//  Created by adam Naji on 01/02/2026.
//
import AppKit

final class MenuController {

    let copyListener: CopyListener
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init(copyListener: CopyListener) {
        self.copyListener = copyListener
        setupMenuBar()
        
        // Only rebuild menu when history actually changes
        copyListener.onHistoryChanged = { [weak self] in
            self?.rebuildMenu()
        }
    }

    func setupMenuBar() {
        if let button = statusItem.button {
            button.title = "📋"
        }

        rebuildMenu()
    }

    // Rebuild menu dynamically
    func rebuildMenu() {
        let menu = NSMenu()

        // Add clipboard history
        let history = copyListener.getHistory()
        if history.isEmpty {
            let item = NSMenuItem(title: "No clipboard history yet", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for (index, clip) in history.prefix(9).enumerated() {
                let text = clip.text
                // Truncate long text for display
                let displayText = text.count > 50
                    ? String(text.prefix(47)) + "..."
                    : text
                
                let item = NSMenuItem(
                    title: displayText.replacingOccurrences(of: "\n", with: " "),
                    action: #selector(copyToClipboard(_:)),
                    keyEquivalent: index < 9 ? "\(index + 1)" : ""
                )
                item.target = self
                item.representedObject = text // Store full text
                menu.addItem(item)
            }
        }

        menu.addItem(NSMenuItem.separator())
        
        // Add clear history option
        if !history.isEmpty {
            let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
            clearItem.target = self
            menu.addItem(clearItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        let finderItem = NSMenuItem(
            title: "Show Finder",
            action: #selector(CopyListener.open),
            keyEquivalent: "f"
        )
        finderItem.target = copyListener
        menu.addItem(finderItem)

        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // Copy a history item to clipboard
    @objc func copyToClipboard(_ sender: NSMenuItem) {
        guard let text = sender.representedObject as? String else { return }
        
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        
        // Show brief notification (optional)
        print("✅ Copied to clipboard")
    }
    
    @objc func clearHistory() {
        copyListener.clearHistory()
    }
}
