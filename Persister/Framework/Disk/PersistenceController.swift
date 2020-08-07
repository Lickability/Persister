//
//  PersistenceController.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public final class PersistenceController: Cache {
    
    // MARK: - Cache
    
    public let expirationPolicy: CacheExpirationPolicy
    
    // MARK: - PersistenceController
    
    private let encoder: PersistenceEncoder
    private let decoder: PersistenceDecoder
    private let diskManager: DiskManager
    private let rootDirectoryURL: URL
    
    public init(encoder: PersistenceEncoder = JSONEncoder(), decoder: PersistenceDecoder = JSONDecoder(), rootDirectoryURL: URL, diskManager: DiskManager = FileManager.default, expirationPolicy: CacheExpirationPolicy = .afterInterval(3600)) {
        self.encoder = encoder
        self.decoder = decoder
        self.rootDirectoryURL = rootDirectoryURL
        self.diskManager = diskManager
        self.expirationPolicy = expirationPolicy
        
        try? removeExpired()
    }
    
    public func write<T: Codable>(item: T, forKey key: String) throws {
        try diskManager.createDirectoryIfNecessary(directoryURL: rootDirectoryURL)

        let filePath = persistencePath(forKey: key)
        
        let data = try encoder.encode(item)
        
        diskManager.write(data, toPath: filePath, expiresOn: expirationPolicy.expirationDate(from: Date()))
    }
    
    public func read<T: Decodable>(forKey key: String) throws -> T? {
        let filePath = persistencePath(forKey: key)
        
        if let entry = diskManager.read(atPath: filePath) {
            if let expirationDate = entry.expiration, expirationDate < Date() {
                try? remove(forKey: key)
                
                throw PersistenceError.objectIsExpired
            } else {
                return try decoder.decode(T.self, from: entry.object)
            }
        } else {
            throw PersistenceError.noValidDataForKey
        }
    }
    
    public func remove(forKey key: String) throws {
        let filePath = persistencePath(forKey: key)

        try diskManager.remove(atPath: filePath)
    }
    
    public func removeAll() throws {
        try diskManager.removeContentsOfDirectory(at: rootDirectoryURL)
    }
    
    public func removeExpired() throws {
        try diskManager.removeExpiredContentsOfDirectory(at: rootDirectoryURL)
    }
        
    private func persistencePath(forKey key: String) -> String {
        return rootDirectoryURL.appendingPathComponent(key).path
    }
}
