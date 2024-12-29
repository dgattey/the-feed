//
//  CacheManager.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import Foundation

/**
 Creates a shared cache for the whole app, set up to cache both in memory and on disk. Use this through `URLSession.shared` by default
 */
struct CacheManager {
    private static let memoryCapacity = 50 * 1024 * 1024 // 50 MB
    private static let diskCapacity = 150 * 1024 * 1024 // 150 MB
    
    static let shared = URLCache(
        memoryCapacity: memoryCapacity,
        diskCapacity: diskCapacity,
        diskPath: nil
    )
}
