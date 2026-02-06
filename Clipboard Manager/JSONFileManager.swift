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
        let formatter = ISO8601DateFormatter()
        let item = Clip(
            date: formatter.string(from: Date()),
            text: string
        )
        
        var items = get()
        
        // Remove duplicates
        items.removeAll { $0.text == string }
        
        // Insert newest at top
        items.insert(item, at: 0)
        
        save(items)
    }
    
    func removeAll() {
        save([])
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
