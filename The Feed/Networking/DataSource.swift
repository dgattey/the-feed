//
//  DataSource.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/25/24.
//

import Foundation

enum DataOrigin: String, CaseIterable, Model {
    case cache
    case network
}

struct DataSource<T: Codable & Equatable & Hashable>: Model {
    let value: T
    let origin: DataOrigin
}
