import SwiftUI
import AppKit
import Combine

// MARK: - Model

struct ClipboardItem: Identifiable, Hashable {
    let id: Int
    let text: String
    let date: Date
    let pinned: Bool
}

// MARK: - Main UI

struct ClipboardWindowView: View {
    
    @StateObject private var copyListener = CopyListenerWrapper(listener: CopyListener.shared)
    @State private var searchText: String = "" // Search text
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // Filtered items based on search
    private var filteredItems: [ClipboardItem] {
        let isoFormatter = ISO8601DateFormatter()
        let allItems = copyListener.history.enumerated().compactMap { index, clip in
            let date: Date
            if let parsed = isoFormatter.date(from: clip.date) {
                date = parsed
            } else {
                date = Date() // fallback
            }
            return ClipboardItem(id: index, text: clip.text, date: date, pinned: clip.pinned ?? false)
        }
        
        if searchText.isEmpty {
            return allItems
        } else {
            return allItems.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            
            if filteredItems.isEmpty {
                VStack {
                    Spacer()
                    Text(searchText.isEmpty ? "📋 Clipboard is empty" : "🔍 No results found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView {
                    content(items: filteredItems)
                        .padding(20)
                }
            }
        }
        .frame(width: 480, height: 620)
        .background(.ultraThinMaterial)
    }
}

// MARK: - UI Components

private extension ClipboardWindowView {
    
    var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Clipboard Manager")
                    .font(.headline)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Search field
            TextField("Search...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
        }
        .padding()
    }
    
    func content(items: [ClipboardItem]) -> some View {
        let pinnedItems = items.filter { $0.pinned }
        let unpinnedItems = items.filter { !$0.pinned }

        let grouped = Dictionary(grouping: unpinnedItems) { Calendar.current.startOfDay(for: $0.date) }
        let sortedDates = grouped.keys.sorted(by: >)
        
        return VStack(alignment: .leading, spacing: 28) {
            // Pinned items section
            if !pinnedItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "pin.fill")
                        Text("Pinned")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(pinnedItems) { item in
                            clipboardCard(item)
                        }
                    }
                }
            }

            // Normal history
            ForEach(sortedDates, id: \.self) { date in
                VStack(alignment: .leading, spacing: 12) {
                    Text(formattedDate(date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(grouped[date] ?? []) { item in
                            clipboardCard(item)
                        }
                    }
                }
            }
        }
    }
    
    func clipboardCard(_ item: ClipboardItem) -> some View {
        ZStack(alignment: .topTrailing) {
            Text(item.text)
                .font(.system(size: 13))
                .lineLimit(4)
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.pinned ? Color.blue.opacity(0.06) : Color.primary.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item.pinned ? Color.blue.opacity(0.2) : Color.primary.opacity(0.06))
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    copyToClipboard(item.text)
                }
            
            Button {
                if item.pinned {
                    copyListener.unpin(item)
                } else {
                    copyListener.pin(item)
                }
            } label: {
                Image(systemName: item.pinned ? "pin.fill" : "pin")
                    .font(.system(size: 10))
                    .foregroundStyle(item.pinned ? .blue : .secondary)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .help(item.pinned ? "Unpin item" : "Pin item")
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// MARK: - Helpers

private extension ClipboardWindowView {
    
    func copyToClipboard(_ text: String) {
        ClipboardUtils.copyToClipboard(text)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

struct ClipboardWindowView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardWindowView()
    }
}
