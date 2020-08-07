//
//  DiskCache.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Describes a type capable of caching items on disk.
public struct DiskCache {
    
    // MARK: - Cache
    
    public let expirationPolicy: CacheExpirationPolicy
    
    // MARK: - DiskCache
    
    private let persister: Persister
    
    /// Creates a new `DiskCache`.
    /// - Parameters:
    ///   - persister: The underlying persister used to store / recall items.
    ///   - expirationPolicy: Determines when newly written items are considered expired. Defaults to expire items in one hour (3600 seconds).
    public init(persister: Persister, expirationPolicy: CacheExpirationPolicy = .afterInterval(3600)) {
        self.persister = persister
        self.expirationPolicy = expirationPolicy
    }
}

extension DiskCache: Cache {
    
    // MARK: - Cache
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        return try persister.read(forKey: key)?.object
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        let entry = DiskEntry(object: item, expiration: expirationPolicy.expirationDate(from: Date()))
        try persister.write(entry: entry, forKey: key)
    }
}
