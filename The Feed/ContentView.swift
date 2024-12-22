//
//  ContentView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(getApiRoute(forType: .Book) ?? "bad data")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
