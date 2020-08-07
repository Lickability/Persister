//
//  LRUCache.swift
//  Persister
//
//  Created by Twig on 5/3/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import UIKit

/// A generic "least-recently-used" cache. Items are purged based on least recent usage depending on the value for `capacity` passed on `init`.
public final class LRUCache<Key: Hashable, Value> {
    private let capacity: CacheCapacity
    private var keysOrderedByRecentUse = [Key]()
    private var backingStoreDictionary = SynchronizedDictionary<Key, Value>()
    private var expirationDictionary = SynchronizedDictionary<Key, Date>()
    
    /// Creates a new `LRUCache`.
    /// - Parameter capacity: The capacity to use for the cache. If the capacity is reached, the least recently used item will be evicted from the cache.
    public init(capacity: CacheCapacity) {
        self.capacity = capacity
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    /// Writes an item to the cache.
    /// - Parameters:
    ///   - item: The item to write to the cache.
    ///   - key: The key that can be used to recall the written item later.
    ///   - date: The date at which the item is considered expired. If `nil`, the item will never expire.
    public func write(_ item: Value, for key: Key, expiresOn date: Date?) {
        
        if let index = keysOrderedByRecentUse.firstIndex(of: key) {
            moveKeyToFrontOfList(key: key, atIndex: index)
            backingStoreDictionary[key] = item
        } else {
            keysOrderedByRecentUse.insert(key, at: keysOrderedByRecentUse.startIndex)
            backingStoreDictionary[key] = item
        }
        
        expirationDictionary[key] = date
        
        switch capacity {
        case .unlimited:
            break
        case let .limited(numberOfItems):
            guard keysOrderedByRecentUse.count > numberOfItems, let leastRecentlyUsedKey = keysOrderedByRecentUse.popLast() else { break }
            backingStoreDictionary[leastRecentlyUsedKey] = nil
        }
    }
    
    /// Reads and returns an item from the cache for the given `key`, if found.
    /// - Parameter key: The key associated with the item when it was written.
    public func read(for key: Key) -> Value? {
        guard let value = backingStoreDictionary[key] else {
            return nil
        }

        if let date = expirationDictionary[key], date < Date() {
            removeItem(for: key)
            return nil
        }
        
        if let index = keysOrderedByRecentUse.firstIndex(of: key) {
            moveKeyToFrontOfList(key: key, atIndex: index)
        }
        
        return value
    }
    
    /// Reads and returns an item from the cache for the given `key`, if found.
    /// - Parameter key: The key associated with the item when it was written.
    public subscript(key: Key) -> Value? {
        return read(for: key)
    }
    
    /// Removes an item associated with the given `key`.
    /// - Parameter key: The key associated with the item when it was written.
    public func removeItem(for key: Key) {
        keysOrderedByRecentUse.removeAll { $0 == key }
        backingStoreDictionary[key] = nil
        expirationDictionary[key] = nil
    }
    
    /// Removes all items from the cache.
    public func removeAllItems() {
        backingStoreDictionary.removeAll()
        keysOrderedByRecentUse.removeAll()
        expirationDictionary.removeAll()
    }
    
    /// Removes all expired items from the cache.
    public func removeExpired() {
        let expirationDictionary = self.expirationDictionary
        expirationDictionary.forEach { key, expirationDate in
            if expirationDate < Date() {
                removeItem(for: key)
            }
        }
    }
    
    private func moveKeyToFrontOfList(key: Key, atIndex index: Int) {
        keysOrderedByRecentUse.remove(at: index)
        keysOrderedByRecentUse.insert(key, at: keysOrderedByRecentUse.startIndex)
    }
    
    @objc private func didReceiveMemoryWarning() {
        removeAllItems()
    }
}
