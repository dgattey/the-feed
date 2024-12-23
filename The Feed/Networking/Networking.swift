//
//  Networking.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 Handles all possible error states from data, response, and error from a network call. Calls handler with all cases.
 */
func handleNetworkResponse(
    data: Data?,
    response: URLResponse?,
    error: Error?,
    completionHandler completion: DataResultCallback
) -> Void {
    if let error = error {
        completion(.failure(.unexpectedError(error)))
        return
    }
    
    guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(.missingData(statusCode: nil)))
        return
    }
    
    switch httpResponse.statusCode {
    case 200...299:
        break
    case 401:
        fallthrough
    case 403:
        completion(.failure(.unauthorized(statusCode: httpResponse.statusCode)))
        return
    case 404:
        completion(.failure(.missingData(statusCode: 404)))
        return
    case 400...499:
        completion(.failure(.badInput(statusCode: httpResponse.statusCode)))
        return
    default:
        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
        return
    }
    
    guard let data = data else {
        completion(.failure(.missingData(statusCode: nil)))
        return
    }
    
    completion(.success(data))
}
