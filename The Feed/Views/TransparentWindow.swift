//
//  TransparentWindow.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/27/24.
//

import SwiftUI

#if os(macOS)
class WindowBackedHelperView: NSView {
    var didMoveToWindow: (NSWindow) -> Void
    
    init(didMoveToWindow: @escaping (NSWindow) -> Void) {
        self.didMoveToWindow = didMoveToWindow
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else {
            return
        }
        didMoveToWindow(window)
    }
}

struct WindowBackedView: NSViewRepresentable {
    typealias NSViewType = WindowBackedHelperView
    
    var didMoveToWindow: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> WindowBackedHelperView {
        WindowBackedHelperView {
            didMoveToWindow($0)
        }
    }
    
    func updateNSView(_ nsView: WindowBackedHelperView, context: Context) {
        
    }
}

struct DidMoveToWindowModifier: ViewModifier {
    var didMoveToWindow: (NSWindow) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                WindowBackedView {
                    didMoveToWindow($0)
                }
            )
    }
}

extension View {
    func didMoveToWindow(_ completion: @convention(block) @escaping (NSWindow) -> Void) -> some View {
        self.modifier(DidMoveToWindowModifier(didMoveToWindow: completion))
    }
}
#endif
