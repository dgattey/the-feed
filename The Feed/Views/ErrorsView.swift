//
//  ErrorsView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a full page error message view
 */
struct ErrorsView: View {
    @EnvironmentObject var errors: ErrorsViewModel
    
    private let maxHeight: CGFloat = 52
    private let maxTextWidth: CGFloat = 300
    private let padding: CGFloat = 8
    
    var body: some View {
        ZStack {
            Color.red.mix(with: Color.background, by: 0.4)
                .frame(idealWidth: .infinity, idealHeight: .infinity)
            ScrollView(.vertical) {
                Group {
                    if (errors.errorCount == 1) {
                        Text("Encountered an error, check console")
                            .font(.headline)
                        Text(errors.errors.first!).textSelection(.enabled)
                    } else if (errors.errorCount > 1) {
                        Text("Encountered \(errors.errorCount) errors, check console")
                            .font(.headline)
                    }
                }
                .lineLimit(nil)
                .frame(width: maxTextWidth - padding)
                .padding(.vertical, padding)
                .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: maxTextWidth, maxHeight: errors.hasErrors ? maxHeight : 0)
            .fixedSize(horizontal: true, vertical: true)
            .defaultScrollAnchor(.top)
            .multilineTextAlignment(.center)
            .offset(y: errors.hasErrors ? 0 : maxHeight)
            #if os(iOS)
            // Layout specific to iOS (otherwise overflows on macOS)
            .safeAreaPadding(.bottom, 16)
            .clipped()
            #endif
        }
        .animation(errors.hasErrors)
        .frame(maxHeight: errors.hasErrors ? maxHeight : 0, alignment: .bottom)
    }
}
