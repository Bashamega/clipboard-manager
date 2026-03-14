//
//  JSONFileManager.swift
//  Clipboard Manager
//
//  Created by adam Naji on 06/02/2026.
//

import Foundation
import AppKit

final class JSONFileManager {
    
    // Nested Codable struct
    struct Clip: Codable {
        let date: String
        let text: String
        let pinned: Bool?
    }
    
    private let fileName: String
    
    init(fileName: String = "clipboardHistory.json") {
        self.fileName = fileName
    }
    
    // MARK: - File Path
    
    func getFileURL() -> URL {
        let fileManager = FileManager.default
        
        do {
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let folder = appSupport.appendingPathComponent("ClipboardManager", isDirectory: true)
            
            if !fileManager.fileExists(atPath: folder.path) {
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
            
            return folder.appendingPathComponent(fileName)
            
        } catch {
            print("❌ Failed to access Application Support, using Documents: \(error)")
            let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0].appendingPathComponent(fileName)
        }
    }
    
    // MARK: - Read
    
    func get() -> [Clip] {
        let url = getFileURL()
        guard let data = try? Data(contentsOf: url) else { return [] }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([Clip].self, from: data)) ?? []
    }
    
    // MARK: - Write
    
    func add(_ string: String) {
        var items = get()
        let existingItem = items.first { $0.text == string }
        let pinned = existingItem?.pinned ?? false
        
        // Remove duplicates
        items.removeAll { $0.text == string }
        
        let formatter = ISO8601DateFormatter()
        let item = Clip(
            date: formatter.string(from: Date()),
            text: string,
            pinned: pinned
        )
        
        // Insert newest at top
        items.insert(item, at: 0)
        
        save(items)
    }
    
    func removeUnpinned() {
        let items = get()
        let pinnedItems = items.filter { $0.pinned ?? false }
        save(pinnedItems)
    }
    
    /// Pin an item by its text, sets pinned to true
    func pinItem(_ text: String) {
        var items = get()
        guard let idx = items.firstIndex(where: { $0.text == text }) else { return }

        let oldItem = items[idx]
        let newItem = Clip(date: oldItem.date, text: oldItem.text, pinned: true)
        
        items[idx] = newItem
        save(items)
    }

    /// Unpin an item by its text, sets pinned to false (or nil)
    func unpinItem(_ text: String) {
        var items = get()
        guard let idx = items.firstIndex(where: { $0.text == text }) else { return }

        let oldItem = items[idx]
        let newItem = Clip(date: oldItem.date, text: oldItem.text, pinned: false)
        
        items[idx] = newItem
        save(items)
    }
    
    // MARK: - Private Save
    
    private func save(_ items: [Clip]) {
        let url = getFileURL()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(items)
            try data.write(to: url)
        } catch {
            print("❌ Error saving JSON: \(error)")
        }
    }
}
