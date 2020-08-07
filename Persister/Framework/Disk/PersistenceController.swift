//
//  PersistenceController.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public final class PersistenceController: Persister {
    private let encoder: PersistenceEncoder
    private let decoder: PersistenceDecoder
    private let diskManager: DiskManager
    private let rootDirectoryURL: URL
    
    public init(encoder: PersistenceEncoder = JSONEncoder(), decoder: PersistenceDecoder = JSONDecoder(), rootDirectoryURL: URL, diskManager: DiskManager = FileManager.default) {
        self.encoder = encoder
        self.decoder = decoder
        self.rootDirectoryURL = rootDirectoryURL
        self.diskManager = diskManager
        
        try? removeExpired()
    }
    
    public func write<T: Codable>(entry: DiskEntry<T>, forKey key: String) throws {
        try diskManager.createDirectoryIfNecessary(directoryURL: rootDirectoryURL)

        let filePath = persistencePath(forKey: key)
        
        let data = try encoder.encode(entry.object)
        
        diskManager.write(data, toPath: filePath, expiresOn: entry.expiration)
    }
    
    public func read<T: Decodable>(forKey key: String) throws -> DiskEntry<T>? {
        let filePath = persistencePath(forKey: key)
        
        if let entry = diskManager.read(atPath: filePath) {
            if let expirationDate = entry.expiration, expirationDate < Date() {
                try? remove(forKey: key)
                
                throw PersistenceError.objectIsExpired
            } else {
                let object = try decoder.decode(T.self, from: entry.object)
                
                return DiskEntry(object: object, expiration: entry.expiration)
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
