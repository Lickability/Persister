//
//  PersistenceEncoder.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Describes a type capable of encoding items into `Data`.
public protocol PersistenceEncoder {
    
    /// Encodes the specified item into `Data`.
    /// - Parameter item: The item to encode.
    func encode<T: Encodable>(_ item: T) throws -> Data
}

extension JSONEncoder: PersistenceEncoder { }
extension PropertyListEncoder: PersistenceEncoder { }
