//
//  ItemEncoder.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Describes a type capable of encoding items into `Data`.
public protocol ItemEncoder: Sendable {
    
    /// Encodes the specified item into `Data`.
    /// - Parameter item: The item to encode.
    func encode<Item: Encodable>(_ item: Item) throws -> Data
}

extension JSONEncoder: ItemEncoder { }
extension PropertyListEncoder: ItemEncoder { }
