import SwiftUI
import ApplicationServices

struct AccessibilityStatusView: View {
    @State private var isTrusted = AXIsProcessTrusted()
    @State private var timer: Timer?

    var body: some View {
        VStack {
            if !isTrusted {
                // ✅ Use the separate enabled UI
                ClipboardWindowView()
            } else {
                // ❌ Disabled UI (keep original)
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)

                        Text("Accessibility Disabled")
                            .font(.headline)
                    }

                    Text("Please enable accessibility permission to allow clipboard monitoring.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Open System Settings") {
                        openAccessibilitySettings()
                    }
                    .buttonStyle(.borderedProminent)

                    Text("After enabling, you can close this window.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(width: 380)
            }
        }
        .onAppear { startPolling() }
        .onDisappear { stopPolling() }
    }

    // MARK: - Polling
    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            let trusted = AXIsProcessTrusted()
            if trusted != isTrusted {
                withAnimation(.easeInOut) {
                    isTrusted = trusted
                }
            }
        }
    }

    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Open Accessibility Settings
    private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
