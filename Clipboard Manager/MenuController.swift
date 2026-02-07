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

    init(copyListener: CopyListener = CopyListener.shared) {
        self.copyListener = copyListener
        setupMenuBar()

        // Add an observer instead of overwriting a single callback
        copyListener.addObserver { [weak self] in
            DispatchQueue.main.async {
                self?.rebuildMenu()
            }
        }
    }

    func setupMenuBar() {
        if let button = statusItem.button {
            button.title = "📋"
        }

        rebuildMenu()
    }

    func rebuildMenu() {
        let menu = NSMenu()

        let history = copyListener.getHistory()
        if history.isEmpty {
            let item = NSMenuItem(title: "No clipboard history yet", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for (index, clip) in history.prefix(9).enumerated() {
                let text = clip.text
                let displayText = text.count > 50
                    ? String(text.prefix(47)) + "..."
                    : text
                
                let item = NSMenuItem(
                    title: displayText.replacingOccurrences(of: "\n", with: " "),
                    action: #selector(copyMenuItem(_:)),
                    keyEquivalent: index < 9 ? "\(index + 1)" : ""
                )
                item.target = self
                item.representedObject = text
                menu.addItem(item)
            }
        }

        menu.addItem(NSMenuItem.separator())

        if !history.isEmpty {
            let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistoryMenuItem), keyEquivalent: "")
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

    @objc private func copyMenuItem(_ sender: NSMenuItem) {
        guard let text = sender.representedObject as? String else { return }
        ClipboardUtils.copyToClipboard(text)
    }
    
    @objc private func clearHistoryMenuItem() {
        ClipboardUtils.clearHistory(copyListener)
    }
}
