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
    private let maxHistory = 5

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            if event.modifierFlags.contains(.command),
               event.keyCode == 8 { // Cmd+C
                // Delay reading clipboard slightly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    let pb = NSPasteboard.general
                    if let text = pb.string(forType: .string), !text.isEmpty {
                        print("📋 Copied text:", text)
                        if self.history.first != text {
                            self.history.insert(text, at: 0)
                            if self.history.count > self.maxHistory {
                                self.history.removeLast()
                            }
                        }
                    }
                }
            }
        }
    }
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func getHistory() -> [String] {
        history
    }
}
