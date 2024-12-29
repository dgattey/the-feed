//
//  Color.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/29/24.
//

import SwiftUI

extension Color {
    /*
     A color slightly more background color than accent color, used for backgrounds with accents
     */
    static let backgroundAccent = Color.accentColor.mix(with: Color.background, by: 0.2)
    
    /**
     A semi-transparent background color to allow glass backgrounds to show through with transparency. Use sparingly for blending/perf.
     */
    static let backgroundGlass = Color.background.opacity(0.65)
}
