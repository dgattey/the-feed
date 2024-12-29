//
//  ServerError.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

/**
 A generic server error that can be used to pull out messages/etc from a raw network response
 */
struct ServerError: Model {
    let message: String
    let code: String?
}
