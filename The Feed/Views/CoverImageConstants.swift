//
//  CoverImageConstants.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import Foundation

struct CoverImageConstants {
    static let cornerRadius: CGFloat = 6
    static let hoverScaleFactor: CGFloat = 1.02
    static let aspectRatio: CGFloat = 1/1.5
    static let errorImagePadding: CGFloat = 16
    
#if os(macOS)
    static let minWidth: CGFloat = 40
    static let maxWidth: CGFloat = 64
    static let maxErrorImageHeight: CGFloat = 40
    static let nonImageGridCellColumns = 4
#else
    static let minWidth: CGFloat = 32
    static let maxWidth: CGFloat = 44
    static let maxErrorImageHeight: CGFloat = 36
    static let nonImageGridCellColumns = 5
#endif
}
