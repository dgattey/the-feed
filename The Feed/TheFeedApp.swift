//
//  TheFeedApp.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI
import Combine

@main
struct TheFeedApp: App {
    @State private var cancellables = Set<AnyCancellable>()
    @StateObject var errorsViewModel = ErrorsViewModel()
    private static let refreshOnWindowActive = false
    
    var body: some Scene {
        WindowGroup {
            EntriesSplitView(errorsViewModel)
                .foregroundStyle(Color.foreground)
                .background(Color.backgroundGlass)
            
                .environmentObject(errorsViewModel)
                .onAppear {
                    setUpRefreshOnWindowActive()
                }
                .onDisappear {
                    cancellables.removeAll()
                }
            #if os(macOS)
                // Calling platform-specific code
                .didMoveToWindow { window in
                    window.isOpaque = false
                    window.backgroundColor = NSColor(Color.clear)
                }
                .background(.ultraThinMaterial)
            #endif
        }
        .commands {
            MenuBarCommands()
        }
    }
    
    /**
     Sets up a notification publish of the refresh data notification when the window newly becomes active/key. Only usable on macOS.
     */
    func setUpRefreshOnWindowActive() {
        #if os(macOS)
        // Calling platform specific code
        guard let window = NSApplication.shared.windows.first else {
            return
        }
        
        // Trigger a refresh when the window newly becomes active
        if (TheFeedApp.refreshOnWindowActive) {
            NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification, object: window)
                .sink { _ in
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                }
                .store(in: &cancellables)
        }
        #endif
    }
}
