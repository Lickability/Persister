//
//  ItemContainer.swift
//  Persister
//
//  Created by Twig on 9/16/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import Foundation

/// A container that holds the item and associated metadata.
public struct ItemContainer<Item: Codable> {
    
    /// The item that is persisted.
    public let item: Item
    
    /// The date the item expires, if it expires.
    public let expirationDate: Date?
}
