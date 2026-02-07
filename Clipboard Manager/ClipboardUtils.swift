//
//  ClipboardUtils.swift
//  Clipboard Manager
//
//  Created by Adam Naji on 07/02/2026.
//

import AppKit

struct ClipboardUtils {
    
    /// Copies the given text to the system clipboard
    static func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        print("✅ Copied to clipboard")
    }
    
    /// Clears the history of the given CopyListener
    static func clearHistory(_ listener: CopyListener) {
        listener.clearHistory()
        print("🗑️ Clipboard history cleared")
    }
}
