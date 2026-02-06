//
//  Listener.swift
//  Clipboard Manager
//
//  Created by adam Naji on 01/02/2026.
//

import AppKit

final class CopyListener {
    private var monitor: Any?
    private var history: [String] = []
    private let maxHistory = 10
    private var changeCount: Int = 0
    private var timer: Timer?
    
    // Callback when history changes
    var onHistoryChanged: (() -> Void)?

    func start() {
        // Initialize with current clipboard count
        changeCount = NSPasteboard.general.changeCount
        
        // Poll clipboard for changes every 0.3 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        // Check if clipboard has changed
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount
        
        // Get the new clipboard text
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        
        // Don't add duplicates that are already at the top
        guard history.first != text else { return }
        
        print("📋 Clipboard changed:", text.prefix(50))
        
        // Add to history
        history.removeAll { $0 == text } // Remove if exists elsewhere
        history.insert(text, at: 0)
        
        // Trim to max size
        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }
        
        // Notify that history changed
        onHistoryChanged?()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    func getHistory() -> [String] {
        history
    }
    
    func clearHistory() {
        history.removeAll()
        onHistoryChanged?()
    }
}
