//
//  MemoryCache.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Describes a type capable of caching items in memory.
public struct MemoryCache {
    
    // MARK: - Cache
    
    public let expiration: CacheExpiration
    
    // MARK: - MemoryCache
    
    private let cache: LRUCache<String, Any>
    
    /// Creates a new `MemoryCache`.
    /// - Parameters:
    ///   - cache: The underlying cache used to store / recall items.
    ///   - expiration: Determines when newly written items are considered expired. Defaults to expire items in 10 minutes (600 seconds).
    public init(cache: LRUCache<String, Any>, expiration: CacheExpiration = .afterInterval(600)) {
        self.cache = cache
        self.expiration = expiration
    }
}

extension MemoryCache: Cache {
    
    // MARK: - Cache
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        return cache[key] as? T
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        cache.set(item, for: key, expiresOn: expiration.expirationDate(from: Date()))
    }
}

private extension CacheExpiration {
    
    func expirationDate(from date: Date) -> Date? {
        switch self {
        case .never:
            return nil
        case .afterInterval(let interval):
            return date.addingTimeInterval(interval)
        }
    }
}
