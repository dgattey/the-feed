//
//  TheFeedApp.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI

@main
struct TheFeedApp: App {
    var body: some Scene {
        WindowGroup {
            EntriesSplitView()
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Refresh data") {
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                }
                .keyboardShortcut(KeyboardShortcut("r", modifiers: .command))
                Button("Deselect item") {
                    NotificationCenter.default.post(name: .deselectItem, object: nil)
                }
                .keyboardShortcut(KeyboardShortcut("d", modifiers: .command))
            }
        }
    }
}

extension Notification.Name {
    static let refreshData = Notification.Name("refreshData")
    static let deselectItem = Notification.Name("deselectItem")
}
