//
//  AssetViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/26/24.
//


import Foundation
import Combine
import SwiftUI

/**
 Fetches and parses one asset.
 */

class AssetViewModel: ViewModel {
    private var assetId: String
    private var asset: Asset?
    @Published var imageData: Data?
    
    init(_ link: AssetLink) {
        self.assetId = link.id
    }
    
    /**
     Fetches the asset first, then uses that response to get the actual image data
     */
    func fetchData() {
        let publisher = NetworkManager.getDataTaskPublisher(
            forType: .asset(assetId: assetId)
        )
        fetchData(publisher) { dataSource in
            let asset: Asset = dataSource.value
            self.asset = asset
            self.fetchImage(asset)
        }
    }
    
    /**
     Fetches the image data using the asset
     */
    private func fetchImage(_ asset: Asset) {
        let publisher = NetworkManager.getDataTaskPublisher(
            forType: .url(
                asset.file.url
                    .replacingOccurrences(of: "//", with: "https://")
            ),
            printDebugInfo: true,
            disableCache: true
        )
        fetchData(publisher) { dataSource in
            let image: ImageWrapper = dataSource.value
            
            if dataSource.origin == .network {
                self.isLoading = false
            }
        }
    }
    
    class ImageWrapper: EmptyCreatableModel {
        let data: Data
        
        required init() {
            data = Data()
        }
        
        required init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.data = try container.decode(Data.self)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(data)
        }
        
        static func == (lhs: ImageWrapper, rhs: ImageWrapper) -> Bool {
            return lhs.data == rhs.data
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(data)
        }
        
    }
}
