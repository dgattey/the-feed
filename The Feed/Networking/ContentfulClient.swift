//
//  ContentfulClient.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

struct ContentfulClient {
    /**
     All the routes for the content we'd like to load
     */
    enum ContentType: String {
         case entries = "entries"
    }
    
    /**
     Loads API key from the environment variables for this schema. Go to Product > Scheme > Edit Scheme > Environment Variables to set it to a value from [Contentful's CMA tokens](https://app.contentful.com/account/profile/cma_tokens).
     */
    private static var apiKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["CONTENTFUL_API_KEY"] else {
            assert(false, "Please set CONTENTFUL_API_KEY")
        }
        return apiKey
    }

    /**
     Loads the space's ID from environment variables for this schema to construct a base API URL. Go to Product > Scheme > Edit Scheme > Environment Variables to set it to a value from [Contentful's space url](https://app.contentful.com/spaces)
     */
    private static var baseApiUrl: URL {
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
     Returns a constructed URL for the content type
     */
    private static func getApiUrl(forType type: ContentType, withObject: String? = nil) -> URL {
        return baseApiUrl.appendingPathComponent(type.rawValue)
    }
    
    /**
     Sets up a proper URL request and data task for a given content type, method, and object, then runs the data task to run the callback. Handles errors and missing data appropriately to hit the callback with a standardized set of data.
     */
    private static func runDataTask(forType type: ContentType,
                     httpMethod: HttpMethod,
                     withObject object: String? = nil,
                     completion: @escaping DataResultCallback
    ) -> Void {
        let url = getApiUrl(forType: type, withObject: object)
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            return handleNetworkResponse(data: data, response: response, error: error, completionHandler: completion)
        }
        task.resume()
    }
    
    /**
     Runs a GET for content with the given callback
     */
    static func fetchData(
        forType type: ContentType,
        withObject object: String? = nil,
        completion: @escaping DataResultCallback
    ) -> Void {
        return runDataTask(forType: type, httpMethod: .get, completion: completion)
    }
}
