//
//  NetworkError.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

typealias DataResult = Result<Data, NetworkError>
typealias DataResultCallback = (DataResult) -> Void

enum NetworkError: Error, LocalizedError {
    case redirectionError(String)
    // 401/403 unauthorized
    case unauthorized(String)
    // Some other 4xx error
    case clientError(String)
    // Some 5xx error
    case serverError(String)
    // Couldn't decode the response properly
    case decodingError(DecodingError)
    // Malformed data/response
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .redirectionError(let message):
            fallthrough
        case .unauthorized(let message):
            fallthrough
        case .clientError(let message):
            fallthrough
        case .serverError(let message):
            return message
        case .decodingError(let error):
            switch(error) {
            case .valueNotFound(let value, let context):
                return "Decoding error: \(value) not found: \(context.underlyingError?.localizedDescription ?? context.debugDescription)"
            case .dataCorrupted(let context):
                return "Decoding error from corrupted data: \(context.debugDescription) \(context.underlyingError.debugDescription)"
            case .typeMismatch(let type, let context):
                return "Decoding error: \(type) mismatch: \(context.underlyingError?.localizedDescription ?? context.debugDescription)"
            case .keyNotFound(let key, let context):
                return "Decoding error: \(key) not found: \(context.underlyingError?.localizedDescription ?? context.debugDescription)"
            @unknown default:
                return "Decoding error: \(error.localizedDescription)"
            }
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
    
    /**
     Call this as a `tryMap` before you decode the data for a `dataTaskPublisher` call. It will properly handle all errors and return data or throw a proper error.
     */
    static func handle(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return output.data
        case 300...399:
            throw NetworkError
                .redirectionError(
                    "Redirection occurred with status code \(httpResponse.statusCode)."
                )
        case 401:
            fallthrough
        case 403:
            if let errorMessage = try? JSONDecoder().decode(ServerError.self, from: output.data) {
                throw NetworkError.clientError(errorMessage.message)
            } else {
                throw NetworkError.clientError("Unauthorized with status code \(httpResponse.statusCode).")
            }
        case 400...499:
            if let errorMessage = try? JSONDecoder().decode(ServerError.self, from: output.data) {
                throw NetworkError.clientError(errorMessage.message)
            } else {
                throw NetworkError.clientError("Client error with status code \(httpResponse.statusCode).")
            }
        case 500...599:
            if let errorMessage = try? JSONDecoder().decode(ServerError.self, from: output.data) {
                throw NetworkError.clientError(errorMessage.message)
            } else {
                throw NetworkError.serverError("Server error with status code \(httpResponse.statusCode).")
            }
        default:
            throw NetworkError.invalidResponse
        }
    }
}
