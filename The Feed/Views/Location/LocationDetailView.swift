//
//  LocationDetailView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    
    var body: some View {
        Text("Details for \(location.slug)")
            .font(.largeTitle)
            .padding()
    }
}
