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
    var geometry: GeometryProxy
    @EnvironmentObject var errors: ErrorsViewModel
    
    var body: some View {
        let lowerViewHeight = !errors.hasErrors ?
            0 :
            max(48, min(geometry.size.height * 0.12, 64))
        
        ZStack {
            Color.red.mix(with: Color.background, by: 0.35).ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVStack(spacing: 4) {
                    if (errors.errorCount == 1) {
                        Text("Encountered an error, check console").font(.headline)
                        Text(errors.errors.first!).textSelection(.enabled)
                    } else if (errors.errorCount > 1) {
                        Text("Encountered \(errors.errorCount) errors, check console")
                            .font(.headline)
                    }
                }
                .padding(16)
                .containerRelativeFrame(.vertical, alignment: .center)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: errors.hasErrors)
        .frame(height: lowerViewHeight)
    }
}
