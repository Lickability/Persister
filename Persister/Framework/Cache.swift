//
//  Cache.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Describes a type capable of performing read and write operations.
public protocol Cache {
    
    /// Determines when newly written items are considered expired. The default value is `never`.
    var expirationPolicy: CacheExpirationPolicy { get }
    
    /// Reads and returns an items from the cache for the given `key`, if found.
    /// - Parameter key: The key associated with the item when it was written.
    func read<T: Codable>(forKey key: String) throws -> T?
    
    /// Writes an item to the cache.
    /// - Parameters:
    ///   - item: The item to write to the cache.
    ///   - key: The key that can be used to recall the written item later.
    func write<T: Codable>(item: T, forKey key: String) throws
    
    /// Removes an item associated with the given `key`.
    /// - Parameter key: The key associated with the item when it was written.
    func remove(forKey key: String) throws
    
    /// Removes all items from the cache.
    func removeAll() throws
    
    /// Removes all expired items from the cache.
    func removeExpired() throws
}

extension Cache {
    
    public var expirationPolicy: CacheExpirationPolicy {
        return .never
    }
}
