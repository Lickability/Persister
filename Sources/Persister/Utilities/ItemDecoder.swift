//
//  ItemDecoder.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Describes a type capable of decoding items from `Data`.
public protocol ItemDecoder {
    
    /// Attempts to decode the `Data` into an instance of the specified type.
    /// - Parameter type: The item to encode.
    func decode<Item: Decodable>(_ type: Item.Type, from data: Data) throws -> Item
}

extension JSONDecoder: ItemDecoder { }
extension PropertyListDecoder: ItemDecoder { }
