//
//  Listener.swift
//  Clipboard Manager
//
//  Created by adam Naji on 01/02/2026.
//

import AppKit
import Foundation

final class CopyListener {
    
    private var changeCount: Int = 0
    private var timer: Timer?
    
    // JSON file manager for persisting history
    private let storage = JSONFileManager()
    
    // Callback when history changes
    var onHistoryChanged: (() -> Void)?
    
    @objc func open(){
        let fileURL = URL(fileURLWithPath: storage.getFileURL().path)
        let folderURL = fileURL.deletingLastPathComponent() // Get folder containing the file
        
        if FileManager.default.fileExists(atPath: folderURL.path) {
            NSWorkspace.shared.open(folderURL)
        } else {
            print("❌ Folder does not exist: \(folderURL.path)")
        }
    }
    

    // MARK: - Start / Stop
    func start() {
        changeCount = NSPasteboard.general.changeCount
        
        // Poll clipboard every 0.3 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Clipboard History
    func getHistory() -> [JSONFileManager.Clip] {
        storage.get()
    }
    
    func clearHistory() {
        storage.removeAll()
        onHistoryChanged?()
    }
    
    private func addClip(_ text: String) {
        // Use JSONFileManager's add, but handle duplicates & maxHistory manually
        var currentItems = storage.get()
        
        // Remove if already exists
        currentItems.removeAll { $0.text == text }
        
        // Insert at top
        storage.add(text)
        currentItems = storage.get() // reload after add
        
        onHistoryChanged?()
    }
    
    // MARK: - Private
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount
        
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        guard getHistory().first?.text != text else { return }
        
        print("📋 Clipboard changed:", text.prefix(50))
        addClip(text)
    }
}
