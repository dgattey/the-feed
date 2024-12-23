//
//  LoadingView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
            .scaleEffect(2)
    }
}

#Preview {
    LoadingView()
}
