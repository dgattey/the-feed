//
//  UrlCachedSessionManager.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/24/24.
//

import Foundation

/**
 Creates a shared url session for the whole app, set up to cache both in memory and on disk.
 */
struct UrlCachedSessionManager {
    private static let memoryCapacity = 50 * 1024 * 1024 // 50 MB
    private static let diskCapacity = 150 * 1024 * 1024 // 150 MB
    
    static let sharedCache = URLCache(
        memoryCapacity: memoryCapacity,
        diskCapacity: diskCapacity,
        diskPath: nil
    )
    
    static let shared: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = sharedCache
        return URLSession(configuration: configuration)
    }()
}
