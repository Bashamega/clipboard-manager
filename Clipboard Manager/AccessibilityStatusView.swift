//
//  AccessibilityStatusView.swift
//  Clipboard Manager
//
//  Created by adam Naji on 06/02/2026.
//

import SwiftUI
import ApplicationServices

struct AccessibilityStatusView: View {
    @State private var isTrusted = AXIsProcessTrusted()
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Circle()
                    .fill(isTrusted ? Color.green : Color.red)
                    .frame(width: 12, height: 12)

                Text(isTrusted ? "Accessibility Enabled" : "Accessibility Disabled")
                    .font(.headline)
            }

            Text(isTrusted
                 ? "Your clipboard manager is running. Check the menu bar (📋) to see your clipboard history."
                 : "Please enable accessibility permission to allow clipboard monitoring.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if !isTrusted {
                Button("Open System Settings") {
                    openAccessibilitySettings()
                }
                .buttonStyle(.borderedProminent)
                
                Text("After enabling, you can close this window.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Button("Close Window") {
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .frame(width: 380)
        .onAppear {
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            let trusted = AXIsProcessTrusted()
            if trusted != isTrusted {
                isTrusted = trusted
            }
        }
    }
    
    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
