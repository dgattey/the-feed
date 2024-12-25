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
         case entries
    }

    /**
     Create a file with a struct called Secrets if this is erroring. We use two secrets to construct a base API URL from [Contentful's space url](https://app.contentful.com/spaces) and a [personal access token from CMA tokens](https://app.contentful.com/account/profile/cma_tokens).
     */
    private static var baseApiUrl: URL? {
        let spaceId = Secrets.contentfulSpaceId
        let baseApiRoute = "https://api.contentful.com/spaces/\(spaceId)/environments/main/"
        guard let baseApiUrl = URL(string: baseApiRoute) else {
            assert(false, "Could not construct URL")
            return nil
        }
        return baseApiUrl.appending(queryItems: [
            .init(name: "access_token", value: Secrets.contentfulApiKey)
        ])
    }
    
    /**
     Forms the full URL using any associated objects as needed
     */
    private static func getUrl(forType type: ContentType) -> URL? {
        guard let baseUrl = baseApiUrl else {
            return nil
        }
        switch type {
        case .entries:
            return baseUrl
                .appendingPathComponent(type.rawValue)
                .appending(queryItems: [
                    .init(name: "limit", value: "1000") // todo: @dgattey eventually remove this and do real pagination
                ])
        }
    }
    
    /**
     Returns a publisher set up to handle errors for later use.
     */
    static func getDataTaskPublisher(
        forType type: ContentType
    ) -> AnyPublisher<Data, Error>? {
        guard let url = getUrl(forType: type) else {
            return nil
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(NetworkError.handle)
            .eraseToAnyPublisher()
    }
}
