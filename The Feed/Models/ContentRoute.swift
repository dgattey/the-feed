//
//  ContentRoute.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 This must be set in Product > Scheme > Edit Scheme > Environment Variables
 to a value from [Contentful's CMA tokens](https://app.contentful.com/account/profile/cma_tokens)
 */
let apiKeyName = "CONTENTFUL_API_KEY"

/**
 All the routes for the content we'd like to load
 */
enum ContentType: String {
     case Book = "/books"
}

private func loadApiKey() -> String? {
    guard let apiKey = ProcessInfo.processInfo.environment[apiKeyName] else {
        print("Problem fetching key \(apiKeyName)")
        return nil
    }
    return apiKey
}

/**
 Allows fetching the API route for a type of content and optional object
 */
func getApiRoute(forType: ContentType, withObject: String? = nil) -> String? {
    guard let apiKey = loadApiKey() else {
        return nil
    }
    print("Got API Key \(apiKey)")
    return apiKey
}
