//
//  Listener.swift
//  Clipboard Manager
//
//  Created by adam Naji on 01/02/2026.
//

import AppKit
import Foundation

final class CopyListener {
    
    // MARK: - Singleton Instance
    static let shared = CopyListener()
    private init() {} // private init prevents creating new instances

    // MARK: - Properties
    private var changeCount: Int = 0
    private var timer: Timer?
    
    // JSON file manager for persisting history
    private let storage = JSONFileManager()
    // MARK: - Clipboard Listeners
    private var historyObservers: [() -> Void] = []

    // Add a new observer
    func addObserver(_ observer: @escaping () -> Void) {
        historyObservers.append(observer)
    }

    // Notify all observers
    private func notifyObservers() {
        for observer in historyObservers {
            observer()
        }
    }
    // MARK: - Open Storage Folder
    @objc func open() {
        let fileURL = URL(fileURLWithPath: storage.getFileURL().path)
        let folderURL = fileURL.deletingLastPathComponent()
        
        if FileManager.default.fileExists(atPath: folderURL.path) {
            NSWorkspace.shared.open(folderURL)
        } else {
            print("❌ Folder does not exist: \(folderURL.path)")
        }
    }

    // MARK: - Start / Stop Clipboard Monitoring
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
        notifyObservers()
    }
    
    private func addClip(_ text: String) {
        var currentItems = storage.get()
        currentItems.removeAll { $0.text == text } // remove duplicates
        storage.add(text)
        currentItems = storage.get()
        notifyObservers()
    }
    
    // MARK: - Private Clipboard Checking
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
