import SwiftUI
import AppKit
import Combine

// MARK: - Model

struct ClipboardItem: Identifiable, Hashable {
    let id: Int
    let text: String
    let date: Date
}

// MARK: - Main UI

struct ClipboardWindowView: View {
    
    @StateObject private var copyListener = CopyListenerWrapper(listener: CopyListener.shared)
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var items: [ClipboardItem] {
        let isoFormatter = ISO8601DateFormatter()
        return copyListener.history.enumerated().compactMap { index, clip in
            let date: Date
            if let parsed = isoFormatter.date(from: clip.date) {
                date = parsed
            } else {
                date = Date() // fallback
            }
            return ClipboardItem(id: index, text: clip.text, date: date)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            
            if items.isEmpty {
                // Empty state
                VStack {
                    Spacer()
                    Text("📋 Clipboard is empty")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView {
                    content
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
        }
        .padding()
    }
    
    var content: some View {
        let grouped = Dictionary(grouping: items) { Calendar.current.startOfDay(for: $0.date) }
        let sortedDates = grouped.keys.sorted(by: >)
        
        return VStack(alignment: .leading, spacing: 28) {
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
        Text(item.text)
            .font(.system(size: 13))
            .lineLimit(4)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.06))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                copyToClipboard(item.text)
            }
            .help("Click to copy")
            // Add pointer cursor on hover
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
