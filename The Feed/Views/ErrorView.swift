//
//  ErrorView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct ErrorView: View {
    let error: String
    
    var body: some View {
        Section {
            Text("Error")
                .font(.title)
                .foregroundColor(.red)
            Text(error)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}
