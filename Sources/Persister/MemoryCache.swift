//
//  MemoryCache.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Caches items in memory. Items are purged based on least recent usage depending on the value for `capacity` passed on `init`.
public struct MemoryCache {
    
    // MARK: - Cache
    
    public let expirationPolicy: CacheExpirationPolicy
    
    // MARK: - MemoryCache
    
    private let cache: LRUCache<String, Any>
    
    /// Creates a new `MemoryCache`.
    /// - Parameters:
    ///   - capacity: The capacity to use for the cache. If the capacity is reached, the least recently used item will be evicted from the cache.
    ///   - expirationPolicy: Determines when newly written items are considered expired. Defaults to expire items in 10 minutes (600 seconds).
    public init(capacity: CacheCapacity, expirationPolicy: CacheExpirationPolicy = .afterInterval(600)) {
        self.cache = LRUCache(capacity: capacity)
        self.expirationPolicy = expirationPolicy
    }
}

extension MemoryCache: Cache {
    
    // MARK: - Cache
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        return cache[key] as? T
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        cache.write(item, for: key, expiresOn: expirationPolicy.expirationDate(from: Date()))
    }
    
    public func remove(forKey key: String) throws {
        cache.removeItem(for: key)
    }
    
    public func removeAll() throws {
        cache.removeAllItems()
    }
    
    public func removeExpired() throws {
        cache.removeExpired()
    }
}
