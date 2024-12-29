//
//  URLSession.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import Foundation

extension URLSession {
    /**
     Add in caching by default
     */
    static var shared: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = CacheManager.shared
        return URLSession(configuration: configuration)
    }()
}
