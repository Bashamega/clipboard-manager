//
//  MenuController.swift
//  Clipboard Manager
//
//  Created by adam Naji on 01/02/2026.
//
import SwiftUI

@main
struct ClipboardMenuBarApp: App {

    let copyListener = CopyListener()
    var menuController: MenuController!

    init() {
        menuController = MenuController(copyListener: copyListener)

        // Start listener after app launch
        let listener = copyListener
        DispatchQueue.main.async {
            if !Accessibility.checkPermission() {
                Accessibility.promptPermission()
            } else {
                listener.start()
            }
        }

        let menuController = self.menuController
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            menuController?.rebuildMenu()
        }
    }

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
    }
}

