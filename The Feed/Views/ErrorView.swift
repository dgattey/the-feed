//
//  ErrorView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a full page error message view
 */
struct ErrorView: View {
    let error: String
    @State private var copied: Bool = false
    
    var body: some View {
        ZStack {
            Color.background.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(error)
                        .textSelection(.enabled)
                }
                Button {
#if os(iOS)
                    UIPasteboard.general.string = error
#else
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(error, forType: .string)
#endif
                    copied.toggle()
                } label: {
                    if (copied) {
                        Label("Copied error!", systemImage: "checkmark.circle")
                    } else {
                        Text("Copy error to clipboard")
                    }
                }
                .controlSize(.extraLarge)
            }
            .padding()
            .frame(maxWidth: 400)
        }
    }
}
