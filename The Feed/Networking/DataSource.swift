//
//  DataSource.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/25/24.
//

import Foundation

enum DataOrigin: String, Codable, Hashable, Equatable, CaseIterable {
    case cache
    case network
}

struct DataSource<T: Codable & Equatable & Hashable>: Codable, Hashable, Equatable {
    let value: T
    let origin: DataOrigin
}
