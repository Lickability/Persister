//
//  Persister.swift
//  Persister
//
//  Created by Twig on 5/16/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Caches items in memory and on disk using the underlying caches provided on `init`. Items are attempted to be read from memory first before using the disk cache. Expired items will not be automatically removed from the `Persister`, but can be removed using the `removeExpired` function.
public struct Persister {
    private let memoryCache: Cache
    private let diskCache: Cache
    
    /// Creates a new `Persister`.
    /// - Parameters:
    ///   - memoryCache: The underlying memory cache.
    ///   - diskCache: The underlying disk cache.
    public init(memoryCache: Cache, diskCache: Cache) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

extension Persister: Cache {
    
    // MARK: - Cache
    
    public var expirationPolicy: CacheExpirationPolicy {
        assertionFailure("Persister wraps two caches that can have independent expiration policies. Do not rely on Persister’s expirationPolicy directly.")
        return .never
    }
    
    public func read<Item: Codable>(forKey key: String) throws -> ItemContainer<Item>? {
        if let cachedObject: ItemContainer<Item> = try memoryCache.read(forKey: key) {
            return cachedObject
        }
        
        let persistedObject: ItemContainer<Item>? = try diskCache.read(forKey: key)
        try memoryCache.write(item: persistedObject?.item, forKey: key)
        
        return persistedObject
    }
    
    public func write<Item: Codable>(item: Item, forKey key: String) throws {
        try memoryCache.write(item: item, forKey: key)
        try diskCache.write(item: item, forKey: key)
    }
    
    public func write<Item: Codable>(item: Item, forKey key: String, expirationPolicy: CacheExpirationPolicy) throws {
        try memoryCache.write(item: item, forKey: key, expirationPolicy: expirationPolicy)
        try diskCache.write(item: item, forKey: key, expirationPolicy: expirationPolicy)
    }
    
    public func remove(forKey key: String) throws {
        try memoryCache.remove(forKey: key)
        try diskCache.remove(forKey: key)
    }
    
    public func removeAll() throws {
        try memoryCache.removeAll()
        try diskCache.removeAll()
    }
    
    public func removeExpired() throws {
        try memoryCache.removeExpired()
        try diskCache.removeExpired()
    }
}
