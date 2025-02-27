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
    enum ContentType {
        case entries
        case asset(assetId: String)
        case url(_ urlString: String)
    }

    /**
     Create a file with a struct called Secrets if this is erroring. We use two secrets to construct a base API URL from [Contentful's space url](https://app.contentful.com/spaces) and a [personal access token from CMA tokens](https://app.contentful.com/account/profile/cma_tokens).
     */
    private static var urlOrNil: URL? {
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
        guard let url = urlOrNil else {
            return nil
        }
        let urlWithPagination = url.appending(queryItems: [
            URLQueryItem(name: "limit", value: "\(pagination.limit)"),
            URLQueryItem(name: "skip", value: "\(pagination.skip)")
        ])
        switch type {
        case .asset(let assetId):
            return url
                .appendingPathComponent("assets")
                .appendingPathComponent(assetId)
        case .entries:
            return urlWithPagination
                .appendingPathComponent("entries")
        case .url(let urlString):
            return URL(string: urlString)
        }
    }
    
    /**
     Fetches a cached response for a URL request from the cache and erases it to a publisher
     */
    private static func getCachedResponsePublisher(
        forRequest request: URLRequest,
        printDebugInfo: Bool
    ) -> AnyPublisher<DataSource<Data>, Error>? {
        guard let cachedResponse = CacheManager.shared.cachedResponse(for: request) else {
            return nil
        }
        let data = cachedResponse.data
        if (_isDebugAssertConfiguration() && printDebugInfo) {
            print(
                "Cache call for \(request.url?.absoluteString ?? "???") responded with \(data.count) bytes"
            )
            print(data.prettyJsonString() ?? data)
        }
        return Just(DataSource(value: data, origin: .cache))
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.global(qos: .utility))
            .eraseToAnyPublisher()
    }
    
    /**
     Returns a data task publisher that pulls data from cache and network (reponses are merged together).
     */
    static func getDataTaskPublisher(
        forType type: ContentType,
        withPagination pagination: Pagination = .default,
        printDebugInfo: Bool = false,
        disableCache: Bool = false
    ) -> AnyPublisher<DataSource<Data>, Error>? {
        guard let url = getUrl(forType: type, withPagination: pagination) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadRevalidatingCacheData
        
        let networkCallPublisher = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(NetworkError.handle)
            .retryOnTooManyRequests(maxRetries: 3, delay: 1)
            .map { data in
                if (_isDebugAssertConfiguration() && printDebugInfo) {
                    print(
                        "Network call for \(url.relativeString) responded with \(data.count) bytes"
                    )
                    print(data.prettyJsonString() ?? data)
                }
                return data
            }
            .map { DataSource(value: $0, origin: .network) }
            .receive(on: DispatchQueue.global(qos: .utility))
            .eraseToAnyPublisher()
        
        // If we had a cached response, return the merged publishers of both the cached response and non-cached
        if !disableCache, let cachePublisher = getCachedResponsePublisher(
            forRequest: request,
            printDebugInfo: printDebugInfo
        ) {
            return cachePublisher
                .merge(with: networkCallPublisher)
                .eraseToAnyPublisher()
        }
        
        // Otherwise just the network call
        return networkCallPublisher
        
    }
}
