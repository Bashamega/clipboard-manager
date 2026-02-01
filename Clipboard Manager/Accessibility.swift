//
//  Accessibility.swift
//  Clipboard Manager
//
//  Created by adam Naji on 01/02/2026.
//

import AppKit

struct Accessibility {
    static func checkPermission() -> Bool {
        AXIsProcessTrusted()
    }

    static func promptPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
    }
}
