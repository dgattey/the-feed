//
//  LocationCardView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

struct LocationCardView: View {
    let location: Location
    
    var body: some View {
        Text("Details for \(location.slug)")
            .font(.largeTitle)
            .padding()
    }
}
