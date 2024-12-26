//
//  TextBlockDetailView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/26/24.
//

import SwiftUI

struct TextBlockDetailView: View {
    let textBlock: TextBlock
    
    var body: some View {
        Text("Details for \(textBlock.slug)")
            .font(.largeTitle)
            .padding()
    }
}
