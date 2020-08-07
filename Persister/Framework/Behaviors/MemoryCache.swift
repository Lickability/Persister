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
    
    public let expirationPolicy: CacheExpirationPolicy
    
    // MARK: - MemoryCache
    
    private let cache: LRUCache<String, Any>
    
    /// Creates a new `MemoryCache`.
    /// - Parameters:
    ///   - cache: The underlying cache used to store / recall items.
    ///   - expirationPolicy: Determines when newly written items are considered expired. Defaults to expire items in 10 minutes (600 seconds).
    public init(cache: LRUCache<String, Any>, expirationPolicy: CacheExpirationPolicy = .afterInterval(600)) {
        self.cache = cache
        self.expirationPolicy = expirationPolicy
    }
}

extension MemoryCache: Cache {
    
    // MARK: - Cache
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        return cache[key] as? T
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        cache.set(item, for: key, expiresOn: expirationPolicy.expirationDate(from: Date()))
    }
}

private extension CacheExpirationPolicy {
    
    func expirationDate(from date: Date) -> Date? {
        switch self {
        case .never:
            return nil
        case .afterInterval(let interval):
            return date.addingTimeInterval(interval)
        }
    }
}
