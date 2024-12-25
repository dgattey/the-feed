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
            MenuBarCommands()
        }
    }
}
