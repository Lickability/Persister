//
//  DiskCacheBehavior.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public struct DiskCacheBehavior {
    
    // MARK: - CacheBehavior
    
    public let expirationInterval: TimeInterval
    
    // MARK: - DiskCacheBehavior
    
    private let persister: Persister
    
    public init(persister: Persister, expirationInterval: TimeInterval = 3600) {
        self.persister = persister
        self.expirationInterval = expirationInterval
    }
}

extension DiskCacheBehavior: CacheBehavior {
    
    // MARK: - CacheBehavior
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        return try persister.read(forKey: key)?.object
    }
    
    public func write<T: Codable>(value: T, forKey key: String) throws {
        let entry = DiskEntry(object: value, expiration: Date().addingTimeInterval(expirationInterval))
        try persister.write(entry: entry, forKey: key)
    }
}
