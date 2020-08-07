//
//  PersistenceBehavior.swift
//  Persister
//
//  Created by Twig on 5/16/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public struct PersistenceBehavior {
    
    private let memoryCacheBehavior: CacheBehavior
    private let diskCacheBehavior: CacheBehavior

    public init(memoryCacheBehavior: CacheBehavior, diskCacheBehavior: CacheBehavior) {
        self.memoryCacheBehavior = memoryCacheBehavior
        self.diskCacheBehavior = diskCacheBehavior
    }
}

extension PersistenceBehavior: CacheBehavior {
    
    // MARK: - CacheBehavior
    
    public func read<T: Codable>(forKey key: String) throws -> T? {
        if let cachedObject: T = try memoryCacheBehavior.read(forKey: key) {
            return cachedObject
        }
        
        let persistedObject: T? = try diskCacheBehavior.read(forKey: key)
        try memoryCacheBehavior.write(value: persistedObject, forKey: key)
        
        return persistedObject
    }
    
    public func write<T: Codable>(value: T, forKey key: String) throws {
        try memoryCacheBehavior.write(value: value, forKey: key)
        try diskCacheBehavior.write(value: value, forKey: key)
    }
}
