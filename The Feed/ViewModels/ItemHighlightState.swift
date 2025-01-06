//
//  ItemHighlightState.swift
//  The Feed
//
//  Created by Dylan Gattey on 1/5/25.
//

import Combine

/**
 Documents an item's highlight state - it can be hovered, selected, hovered AND selected, or nothing at all (nil)
 */
enum ItemHighlightStateEnum {
    case none
    case hovered
    case selected
    case both
    
    /**
     If a given state is hovered
     */
    var isHovered: Bool {
        switch self {
        case .hovered, .both:
            return true
        case .selected, .none:
            return false
        }
    }
    
    /**
     If a given state is selected
     */
    var isSelected: Bool {
        switch self {
        case .selected, .both:
            return true
        case .hovered, .none:
            return false
        }
    }
    
    /**
     Creates state from two booleans
     */
    init(isHovered: Bool, isSelected: Bool) {
        switch (isHovered, isSelected) {
        case (true, true): self = .both
        case (true, false): self = .hovered
        case (false, true): self = .selected
        case (false, false): self = .none
        }
    }
}

/**
 Keeps track of the highlight state of an item for its children, and which surface
 */
struct ItemHighlightState: Equatable {
    private let state: ItemHighlightStateEnum
    let surface: Surface?
    
    var isSelected: Bool { state.isSelected }
    
    init(isHovered: Bool, isSelected: Bool, surface: Surface?) {
        self.state = ItemHighlightStateEnum(isHovered: isHovered, isSelected: isSelected)
        self.surface = surface
    }
    
    /**
     Returns true if you're hovering this item on the right surface
     */
    func isHovered(for currentSurface: CurrentSurface) -> Bool {
        state.isHovered && self.surface == currentSurface.surface
    }
}
