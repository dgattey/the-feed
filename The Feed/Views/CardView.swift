//
//  CardView.swift
//  The Feed
//
//  Created by Dylan Gattey on 1/2/25.
//

import SwiftUI

/**
 Shows a card with rounded corners/consistent background/shadow/border for use in over/underlaying. Meant to be flexible. If interactive, shows the background/etc on hover.
 */
struct CardView: View {
    private let hasClearBackground: Bool
    private let showsSelection: Bool
    private let state: ItemHighlightState
    @EnvironmentObject private var currentSurface: CurrentSurface
    
    private var isHovered: Bool {
        state.isHovered(for: currentSurface)
    }
    
    private var isSelected: Bool {
        showsSelection && state.isSelected
    }
    
    /**
     Creates a card that shows on hover/
     */
    init(hasClearBackground: Bool = true,
         _ state: ItemHighlightState,
         showsSelection: Bool = true
    ) {
        self.hasClearBackground = hasClearBackground
        self.showsSelection = showsSelection
        self.state = state
    }
    
    private var fillColor: Color {
        if isSelected || isHovered {
            return .backgroundAccent
        }
        if !hasClearBackground {
            return .backgroundCard
        }
        return .clear
    }
    
    private var shadowColor: Color {
        if isHovered {
            return .cardShadowHovered
        }
        if !hasClearBackground || isSelected {
            return .cardShadow
        }
        return .clear
    }
    
    private var separatorWidth: CGFloat {
        if !hasClearBackground || isSelected || isHovered {
            return 0.5
        }
        return 0
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(fillColor)
            .stroke(.separator, lineWidth: separatorWidth)
            .shadow(color: shadowColor, radius: 2, x: 1, y: 3)
            .frame(maxHeight: !hasClearBackground || state.isSelected ? .infinity : 60)
            .scrollClipDisabled()
    }
}
