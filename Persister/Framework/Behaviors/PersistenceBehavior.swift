//
//  PersistenceBehavior.swift
//  Persister
//
//  Created by Twig on 5/16/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public struct PersistenceBehavior {
    
    private let memoryCacheBehavior: Cache
    private let diskCacheBehavior: Cache

    public init(memoryCacheBehavior: Cache, diskCacheBehavior: Cache) {
        self.memoryCacheBehavior = memoryCacheBehavior
        self.diskCacheBehavior = diskCacheBehavior
    }
}

extension PersistenceBehavior: Cache {
    
    // MARK: - Cache
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        if let cachedObject: T = try memoryCacheBehavior.read(forKey: key) {
            return cachedObject
        }
        
        let persistedObject: T? = try diskCacheBehavior.read(forKey: key)
        try memoryCacheBehavior.write(item: persistedObject, forKey: key)
        
        return persistedObject
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        try memoryCacheBehavior.write(item: item, forKey: key)
        try diskCacheBehavior.write(item: item, forKey: key)
    }
}
