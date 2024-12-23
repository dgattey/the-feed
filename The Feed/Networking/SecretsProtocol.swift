//
//  SecretsProtocol.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

/**
 Implement this file when checking out the repo in a struct called "Secrets". It should contain values  from [Contentful's space url](https://app.contentful.com/spaces) and [Contentful's CMA tokens](https://app.contentful.com/account/profile/cma_tokens).
 */
protocol SecretsProtocol {
    static var contentfulApiKey: String { get }
    static var contentfulSpaceId: String { get }
}
