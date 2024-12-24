//
//  LocationListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct LocationListItemView: View {
    let location: Location
    
    var body: some View {
        VStack {
            Text(location.slug).font(.headline)
        }
    }
}
