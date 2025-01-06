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
    private var asset: Asset?
    private var imageUrl: String?
    @Published private(set) var image: Image?
    
    init(_ link: AssetLink, errorsViewModel: ErrorsViewModel) {
        self.assetId = link.id
        self.imageUrl = nil
        super.init(errorsViewModel)
    }
    
    /**
     A fetch is needed if we have an asset id, we're not currently loading, and we're either missing data or have incorrect data.
     */
    private var fetchIsNeeded: Bool {
        let haveAsset = !assetId.isEmpty
        let missingData = asset == nil || image == nil || imageUrl == nil
        let wrongData = asset?.file.url != imageUrl
        return haveAsset && (missingData || wrongData)
    }
    
    /**
     Resets and then newly fetches data
     */
    func resetAndFetch() {
        self.asset = nil
        self.image = nil
        self.imageUrl = nil
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            self.fetchData()
        }
    }
    
    /**
     Fetches the asset first, then uses that response to get the actual image data. Only fetches if necessary.
     */
    func fetchData() {
        guard fetchIsNeeded else {
            return
        }
        
        let publisher = NetworkManager.getDataTaskPublisher(
            forType: .asset(assetId: assetId)
        )
        fetchData(publisher) { dataSource in
            let asset: Asset = dataSource.value
            if (self.asset == nil || self.asset?.id != asset.id) {
                self.asset = asset
                self.fetchImage(asset)
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
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
            let imageData = justData.data
            #if os(macOS)
            // Platform specific decoding here
            if let nsImage = NSImage(data: imageData) {
                self.image = Image(nsImage: nsImage)
                self.imageUrl = asset.file.url
            } else {
                self.addDecodeError()
            }
            #else
            if let uiImage = UIImage(data: imageData) {
                self.image = Image(uiImage: uiImage)
                self.imageUrl = asset.file.url
            } else {
                self.addDecodeError()
            }
            #endif
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    /**
     Reports a decode error for the image
     */
    private func addDecodeError() {
        self.errorsViewModel.add(
            DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Could not decode image with assetId \(assetId), url: \(asset?.file.url ?? "?")"
                )
            )
        )
    }
}
