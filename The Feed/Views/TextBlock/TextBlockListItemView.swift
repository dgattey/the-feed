//
//  TextBlockListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/26/24.
//

import SwiftUI

struct TextBlockListItemView: View {
    let textBlock: TextBlock
    
    var body: some View {
        VStack {
            Text(textBlock.slug).font(.headline)
        }
    }
}
