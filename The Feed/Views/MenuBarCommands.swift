//
//  MenuBarCommands.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/25/24.
//

import SwiftUI

/**
 Sets up refresh and deselecting items, posted to app via NotificationCenter
 */
struct MenuBarCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            refresh
            deselectItem
        }
    }
    
    var refresh: some View {
        Button("Refresh data") {
            NotificationCenter.default.post(name: .refreshData, object: nil)
        }
        .keyboardShortcut(KeyboardShortcut("r", modifiers: .command))
    }
    
    var deselectItem: some View {
        Button("Deselect item") {
            NotificationCenter.default.post(name: .deselectItem, object: nil)
        }
        .keyboardShortcut(KeyboardShortcut("d", modifiers: .command))
    }
}

extension Notification.Name {
    static let refreshData = Notification.Name("refreshData")
    static let deselectItem = Notification.Name("deselectItem")
}