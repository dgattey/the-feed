//
//  CustomCursorView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/29/24.
//

import SwiftUI

#if os(macOS)
/**
 A platform specific view that sets the cursor to a pointer while the mouse is in the view
 */
struct CustomCursorView: NSViewRepresentable {
    func makeNSView(context: Context) -> CustomCursorNSView {
        return CustomCursorNSView()
    }
    
    func updateNSView(_ nsView: CustomCursorNSView, context: Context) {
        
    }
}

class CustomCursorNSView: NSView {
    
    // Override to set the cursor
    override func resetCursorRects() {
        super.resetCursorRects()
        // Define the area where the custom cursor will apply
        self.addCursorRect(self.bounds, cursor: NSCursor.pointingHand) // Change to desired cursor type
    }
    
    // Optional: Change cursor on mouse enter/exit
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        let trackingArea = NSTrackingArea(rect: self.bounds,
                                           options: [.mouseEnteredAndExited, .activeAlways],
                                           owner: self,
                                           userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.set() // Set custom cursor when mouse enters
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set() // Reset to default arrow cursor when mouse exits
    }
}
#endif
