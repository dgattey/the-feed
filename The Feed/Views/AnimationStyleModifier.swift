//
//  AnimationStyleModifier.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/29/24.
//

import SwiftUI

fileprivate struct AnimationConstant {
    static let extraBounce: CGFloat = 0.2
}

/**
 Applies our standard extra bouncy animation to the given body
 */
func withAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
    return try SwiftUICore.withAnimation(.bouncy(extraBounce: AnimationConstant.extraBounce)) {
        try body()
    }
}

extension View {
    /**
     Adds an extra bouncy animation that triggers when `value` changes
     */
    func animation<V: Equatable>(_ value: V) -> some View {
        self.modifier(AnimationStyleModifier(value: value))
    }
}

struct AnimationStyleModifier<V: Equatable>: ViewModifier {
    let value: V
    
    func body(content: Content) -> some View {
        content.animation(.bouncy(extraBounce: AnimationConstant.extraBounce), value: value)
    }
}
