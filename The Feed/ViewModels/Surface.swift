//
//  Surface.swift
//  The Feed
//
//  Created by Dylan Gattey on 1/5/25.
//

import Combine

enum Surface {
    /**
     The sidebar list
     */
    case sidebar
    
    /**
     The feed of all items if one isn't selected
     */
    case feed
}

/**
 The current surface for this area of the app, equatable to Surface too
 */
class CurrentSurface: ObservableObject, Equatable {
    let surface: Surface
    
    init(_ surface: Surface) {
        self.surface = surface
    }
    
    static func == (lhs: CurrentSurface, rhs: CurrentSurface) -> Bool {
        lhs.surface == rhs.surface
    }
}
