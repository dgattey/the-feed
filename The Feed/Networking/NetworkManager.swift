//
//  NetworkManager.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation
import Combine

struct NetworkManager {
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
    private static func getUrl(
        forType type: ContentType,
        withPagination pagination: Pagination
    ) -> URL? {
        guard let baseUrl = baseApiUrl else {
            return nil
        }
        switch type {
        case .entries:
            return baseUrl
                .appendingPathComponent(type.rawValue)
                .appending(queryItems: [
                    URLQueryItem(name: "limit", value: "\(pagination.limit)"),
                    URLQueryItem(name: "skip", value: "\(pagination.skip)")
                ])
        }
    }
    
    /**
     Fetches a cached response for a URL request from the cache and erases it to a publisher
     */
    private static func getCachedResponsePublisher(
        forRequest request: URLRequest
    ) -> AnyPublisher<DataSource<Data>, Error>? {
        guard let cachedResponse = UrlCachedSessionManager.sharedCache.cachedResponse(for: request) else {
            return nil
        }
        return Just(DataSource(value: cachedResponse.data, origin: .cache))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    /**
     Returns a data task publisher that pulls data from cache and network (reponses are merged together).
     */
    static func getDataTaskPublisher(
        forType type: ContentType,
        withPagination pagination: Pagination
    ) -> AnyPublisher<DataSource<Data>, Error>? {
        guard let url = getUrl(forType: type, withPagination: pagination) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadRevalidatingCacheData
        
        let networkCallPublisher = UrlCachedSessionManager.shared.dataTaskPublisher(for: request)
            .tryMap(NetworkError.handle)
            .map { DataSource(value: $0, origin: .network) }
            .eraseToAnyPublisher()
        
        // If we had a cached response, return the merged publishers of both the cached response and non-cached
        if let cachePublisher = getCachedResponsePublisher(forRequest: request) {
            return cachePublisher
                .merge(with: networkCallPublisher)
                .eraseToAnyPublisher()
        }
        
        // Otherwise just the network call
        return networkCallPublisher
        
    }
}