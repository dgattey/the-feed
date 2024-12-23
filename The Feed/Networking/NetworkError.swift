//
//  NetworkError.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

typealias DataResult = Result<Data, NetworkError>
typealias DataResultCallback = (DataResult) -> Void

enum NetworkError: LocalizedError {
    case badInput(statusCode: Int)
    case unauthorized(statusCode: Int)
    case missingData(statusCode: Int?)
    case serverError(statusCode: Int)
    case unexpectedError(Error)
    case badData(data: Data)
    
    public var errorDescription: String? {
        switch self {
        case .badInput(let statusCode):
            return "Bad input data: \(statusCode)"
        case .unauthorized(statusCode: let statusCode):
            return "Unauthorized: \(statusCode)"
        case .missingData(statusCode: let statusCode):
            return "Missing data: \((statusCode != nil) ? String(describing: statusCode) : "no provided status code")"
        case .serverError(statusCode: let statusCode):
            return "Server error: \(statusCode)"
        case .unexpectedError(let error):
            return "Unexpected error: \(error)"
        case .badData(data: let data):
            return "Bad data: \(data)"
        }
    }
}
