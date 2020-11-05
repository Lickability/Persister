//
//  DiskCache.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Caches items on disk.
public class DiskCache: ObservableObject {
    
    // MARK: - Cache
    
    public let expirationPolicy: CacheExpirationPolicy
    
    // MARK: - DiskCache
    
    private let encoder: ItemEncoder
    private let decoder: ItemDecoder
    private let diskManager: DiskManager
    private let rootDirectoryURL: URL

    /// Creates a new `DiskCache`.
    /// - Parameters:
    ///   - encoder: The object used to encode items to be stored on disk.
    ///   - decoder: The object used to decode items read from disk.
    ///   - rootDirectoryURL: The root directory in which items will be stored.
    ///   - diskManager: The disk manager responsible for file operations.
    ///   - expirationPolicy: Determines when newly written items are considered expired. Defaults to expire items in one hour (3600 seconds).
    public init(encoder: ItemEncoder = JSONEncoder(), decoder: ItemDecoder = JSONDecoder(), rootDirectoryURL: URL, diskManager: DiskManager = FileManager.default, expirationPolicy: CacheExpirationPolicy = .afterInterval(3600)) {
        self.encoder = encoder
        self.decoder = decoder
        self.rootDirectoryURL = rootDirectoryURL
        self.diskManager = diskManager
        self.expirationPolicy = expirationPolicy
    }
}

extension DiskCache: Cache {
    
    // MARK: - Cache
    
    public func write<Item: Codable>(item: Item, forKey key: String) throws {
        try diskManager.createDirectoryIfNecessary(directoryURL: rootDirectoryURL)

        let filePath = persistencePath(forKey: key)
        
        do {
            let data = try encoder.encode(item)
            diskManager.write(data, toPath: filePath, expiresOn: expirationPolicy.expirationDate(from: Date()))
        } catch {
            throw PersistenceError.encodingError(error)
        }
    }
    
    public func read<Item: Decodable>(forKey key: String) throws -> ItemContainer<Item>? {
        let filePath = persistencePath(forKey: key)
        
        if let entry = diskManager.read(atPath: filePath) {
            do {
                let item = try decoder.decode(Item.self, from: entry.item)
                
                return ItemContainer(item: item, expirationDate: entry.expiration)
            } catch {
                throw PersistenceError.decodingError(error)
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
        
    public func allItems<Item: Codable>() throws -> [ItemContainer<Item>] {
        let entries = try diskManager.contentsOfDirectory(at: rootDirectoryURL)
        
        return try entries.compactMap {
            do {
                let item = try decoder.decode(Item.self, from: $0.item)
                
                return ItemContainer(item: item, expirationDate: $0.expiration)
            } catch {
                throw PersistenceError.decodingError(error)
            }
        }
    }
    
    private func persistencePath(forKey key: String) -> String {
        return rootDirectoryURL.appendingPathComponent(key).path
    }
}
