//
//  ContentfulClient.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation
import Combine

struct ContentfulClient {
    /**
     All the routes for the content we'd like to load
     */
    enum ContentType: String {
         case entries = "entries"
    }

    /**
     Create a file with a struct called Secrets if this is missing. It is a value used to construct a base API URL from [Contentful's space url](https://app.contentful.com/spaces)
     */
    private static var baseApiUrl: URL? {
        let spaceId = Secrets.contentfulSpaceId
        let baseApiRoute = "https://api.contentful.com/spaces/\(spaceId)/environments/main/"
        guard let baseApiUrl = URL(string: baseApiRoute) else {
            assert(false, "Could not construct URL")
            return nil
        }
        return baseApiUrl
    }
    
    /**
     Forms the full URL using any case-let objects if needed
     */
    private static func getUrl(forType type: ContentType) -> URL? {
        guard let baseUrl = baseApiUrl else {
            return nil
        }
        switch type {
        case .entries:
            return baseUrl.appendingPathComponent(type.rawValue)
        }
    }
    
    /**
     Returns a publisher set up to handle errors and authenticate properly, for later use.
     */
    static func getDataTaskPublisher(
        forType type: ContentType,
        usingMethod httpMethod: HttpMethod = .get
    ) -> AnyPublisher<Data, Error>? {
        guard let url = getUrl(forType: type) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("Bearer \(Secrets.contentfulApiKey)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(NetworkError.handle)
            .eraseToAnyPublisher()
    }
}
