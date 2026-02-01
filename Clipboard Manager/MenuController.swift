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
            menu.addItem(NSMenuItem(title: "No copies yet", action: nil, keyEquivalent: ""))
        } else {
            for text in history {
                let item = NSMenuItem(title: text, action: #selector(copyAgain(_:)), keyEquivalent: "")
                item.target = self
                menu.addItem(item)
            }
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // Copy a history item again
    @objc func copyAgain(_ sender: NSMenuItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(sender.title, forType: .string)
        rebuildMenu() // move it to top
    }
}

