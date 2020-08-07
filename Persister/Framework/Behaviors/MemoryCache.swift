//
//  MemoryCache.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public struct MemoryCache {
    
    // MARK: - Cache
    
    public let expirationInterval: TimeInterval
    
    // MARK: - MemoryCache
    
    private let cache: LRUCache<String, Any>
    
    public init(cache: LRUCache<String, Any>, expirationInterval: TimeInterval = 600) {
        self.cache = cache
        self.expirationInterval = expirationInterval
    }
}

extension MemoryCache: Cache {
    
    // MARK: - Cache
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        return cache[key] as? T
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        cache.set(item, for: key, expiresOn: Date().addingTimeInterval(expirationInterval))
    }
}
