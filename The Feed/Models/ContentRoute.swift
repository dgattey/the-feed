//
//  ContentRoute.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 Loads API key from the environment variables for this schema. Go to Product > Scheme > Edit Scheme > Environment Variables to set it to a value from [Contentful's CMA tokens](https://app.contentful.com/account/profile/cma_tokens).
 */
private var apiKey: String {
    guard let apiKey = ProcessInfo.processInfo.environment["CONTENTFUL_API_KEY"] else {
        assert(false, "Please set CONTENTFUL_API_KEY")
    }
    return apiKey
}

/**
 Loads the space's ID from environment variables for this schema to construct a base API URL. Go to Product > Scheme > Edit Scheme > Environment Variables to set it to a value from [Contentful's space url](https://app.contentful.com/spaces)
 */
private var baseApiUrl: URL {
    guard let spaceId = ProcessInfo.processInfo.environment["CONTENTFUL_SPACE_ID"] else {
        assert(false, "Please set CONTENTFUL_SPACE_ID")
    }
    let baseApiRoute = "https://api.contentful.com/spaces/\(spaceId)/environments/main/"
    guard let baseApiUrl = URL(string: baseApiRoute) else {
        assert(false, "Could not construct URL")
    }
    return baseApiUrl
}

/**
 All the routes for the content we'd like to load
 */
enum ContentType: String {
     case entries = "entries"
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

/**
 Returns a constructed URL for the content type
 */
private func getApiUrl(forType type: ContentType, withObject: String? = nil) -> URL {
    return baseApiUrl.appendingPathComponent(type.rawValue)
}

/**
 Sets up a proper URL request and data task for a given content type, method, and object, then runs the data task to run the callback.
 */
func runDataTask(forType type: ContentType,
                 httpMethod: HttpMethod,
                 withObject object: String? = nil,
                 completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
    let url = getApiUrl(forType: type, withObject: object)
    let session = URLSession(configuration: .default)
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    let task = session.dataTask(with: request, completionHandler: completionHandler)
    task.resume()
}
