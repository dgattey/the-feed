//
//  ListViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 1/4/25.
//

import SwiftUI

typealias AnyIdentifiableModel = any IdentifiableModel & AnyObject & Equatable

/**
 Holds state for a list of items, with selected state passed in
 */
class ListViewModel: ObservableObject {
    /**
     Documents an item's highlight state - it can be hovered, selected, hovered AND selected, or nothing at all (nil)
     */
    enum ItemHighlightState {
        case hovered
        case selected
        case both
    }
    
    /**
     All items in the list at present - changing it will update statuses/hovered/selected as needed
     */
    @State var items: [AnyIdentifiableModel] = [] {
        didSet {
            let newIds = Set(items.map { $0.id })
            let oldIds = Set(oldValue.map { $0.id })
            
            // Remove no longer existing ids and add newly created ids
            let setToRemove = oldIds.subtracting(newIds)
            setToRemove.forEach { states[$0] = nil }
            let setToAdd = newIds.subtracting(oldIds)
            setToAdd.forEach { states[$0] = .hovered }
            
            // Update selected and hovered if they were removed
            if let selected, setToRemove.contains(selected.id) {
                self.selected = nil
            }
            if let hovered, setToRemove.contains(hovered.id) {
                self.hovered = nil
            }
        }
    }
    
    /**
     State for each item individually
     */
    @Published private(set) var states: [AnyHashable: ItemHighlightState?] = [:]
    
    /**
     Currently selected item - updates states when changed
     */
    @Binding var selected: AnyIdentifiableModel? {
        didSet {
            // Remove selection from old item if existing
            if let oldValue, let oldState = states[oldValue.id] {
                states[oldValue.id] = oldState == .both ? .hovered : nil
            }
            // Add selection to new item if existing
            if let selected, let newState = states[selected.id] {
                states[selected.id] = newState == .hovered ? .both : .selected
            }
        }
    }
    
    /**
     Currently hovered item - updates states when changed
     */
    @Published var hovered: AnyIdentifiableModel? {
        didSet {
            // Remove hover from old item if existing
            if let oldValue, let oldState = states[oldValue.id] {
                states[oldValue.id] = oldState == .both ? .selected : nil
            }
            // Add hover to new item if existing
            if let selected, let newState = states[selected.id] {
                states[selected.id] = newState == .selected ? .both : .hovered
            }
        }
    }
    
    /**
     The selected item must be externally controlled for possible sharing between lists
     */
    init(selected: Binding<AnyIdentifiableModel?>) {
        _selected = selected
    }
}
