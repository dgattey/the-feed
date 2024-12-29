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
    private let assetId: String
    @Published private(set) var asset: Asset?
    @Published private(set) var imageData: Data?
    
    init(_ link: AssetLink, errorsViewModel: ErrorsViewModel) {
        self.assetId = link.id
        super.init(errorsViewModel)
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
            if (self.asset == nil || self.asset?.id != asset.id) {
                self.asset = asset
                self.fetchImage(asset)
            } else if dataSource.origin == .network {
                self.isLoading = false
            }
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
            )
        )
        fetchData(publisher) { dataSource in
            let justData: JustDataResponse = dataSource.value
            self.imageData = justData.data
            
            if dataSource.origin == .network {
                self.isLoading = false
            }
        }
    }
}
