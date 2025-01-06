//
//  TextBlockCardView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

struct TextBlockCardView: View {
    let textBlock: TextBlock
    
    var body: some View {
        Text("Text block card for \(textBlock.slug)")
            .font(.largeTitle)
            .padding()
    }
}
