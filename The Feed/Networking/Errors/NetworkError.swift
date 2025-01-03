//
//  NetworkError.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation
import Combine

typealias DataResult = Result<Data, NetworkError>
typealias DataResultCallback = (DataResult) -> Void

enum NetworkError: Error, LocalizedError {
    case redirectionError(String)
    // 401/403 unauthorized
    case unauthorized(String)
    // 429 too many requests in a short time period
    case tooManyRequests(String)
    // Some other 4xx error
    case clientError(String, status: Int)
    // Some 5xx error
    case serverError(String)
    // Couldn't decode the response properly
    case decodingError(DecodingError)
    // Malformed data/response
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .clientError(let message, let status):
            return "\(status): \(message)"
        case .redirectionError(let message):
            fallthrough
        case .unauthorized(let message):
            fallthrough
        case .tooManyRequests(let message):
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
            if (_isDebugAssertConfiguration()) {
                print("Output.response invalid: \(output.response)")
            }
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
                throw NetworkError.clientError(errorMessage.message, status: httpResponse.statusCode)
            } else {
                throw NetworkError.clientError("Unauthorized", status: httpResponse.statusCode)
            }
        case 429:
            if let errorMessage = try? JSONDecoder().decode(ServerError.self, from: output.data) {
                throw NetworkError.tooManyRequests(errorMessage.message)
            } else {
                throw NetworkError.tooManyRequests("Too many requests")
            }
        case 400...499:
            if let errorMessage = try? JSONDecoder().decode(ServerError.self, from: output.data) {
                throw NetworkError.clientError(errorMessage.message, status: httpResponse.statusCode)
            } else {
                throw NetworkError.clientError("Client error", status: httpResponse.statusCode)
            }
        case 500...599:
            if let errorMessage = try? JSONDecoder().decode(ServerError.self, from: output.data) {
                throw NetworkError.serverError(errorMessage.message)
            } else {
                throw NetworkError.serverError("Server error with status code \(httpResponse.statusCode).")
            }
        default:
            if (_isDebugAssertConfiguration()) {
                print("Unknown status code \(httpResponse.statusCode). Throwing invalid error")
            }
            throw NetworkError.invalidResponse
        }
    }
}

extension Publisher where Output == Data, Failure == Error {
    
    /**
     Retries a request if we get a too many requests error, after a delay
     */
    func retryOnTooManyRequests(maxRetries: Int, delay: TimeInterval) -> AnyPublisher<Data, Error> {
        self.catch { error -> AnyPublisher<Data, Error> in
            guard case NetworkError.tooManyRequests = error else {
                // For other errors, just throw them
                return Fail(error: error).eraseToAnyPublisher()
            }
            
            var attempts = 0
            if (_isDebugAssertConfiguration()) {
                Swift
                    .print(
                        "Too many requests, retrying \(maxRetries)x after \(delay) seconds: \(String(describing: self))"
                    )
                Swift.print("\n")
            }
            return self.delay(for: .seconds(delay), scheduler: RunLoop.current)
                .retry(maxRetries)
                .handleEvents(receiveOutput: { _ in attempts += 1 })
                .filter { _ in attempts < maxRetries }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
