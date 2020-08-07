//
//  Cache.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Determines when newly written items are considered expired.
public enum CacheExpirationPolicy {
    
    /// Items never expire.
    case never
    
    /// Items expire after the associated interval.
    case afterInterval(TimeInterval)
    
    /// Returns the date of expiration for items in the cache
    /// - Parameter referenceDate: The date from which expiration should be calculated. This should usually be the date the item was written.
    func expirationDate(from referenceDate: Date) -> Date? {
        switch self {
        case .never:
            return nil
        case .afterInterval(let interval):
            return referenceDate.addingTimeInterval(interval)
        }
    }
}

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
}

extension Cache {
    
    public var expirationPolicy: CacheExpirationPolicy {
        return .never
    }
}
