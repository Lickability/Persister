//
//  LRUCache.swift
//  Persister
//
//  Created by Twig on 5/3/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import UIKit

public final class LRUCache<Key: Hashable, Value> {
    
    private let capacity: UInt
    private var keysOrderedByRecentUse = [Key]()
    private var backingStoreDictionary = SynchronizedDictionary<Key, Value>()
    private var expirationDictionary = SynchronizedDictionary<Key, Date>()
    
    /// Initializes an LRUCache with the given parameters.
    ///
    /// - Parameter capacity: The capacity to use for the cache. If the capacity is reached, the least recently used object will be evicted from the cache.
    public init(capacity: UInt) {
        self.capacity = capacity
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    /// Sets the given value for the specified key in the cache.
    ///
    /// - Parameters:
    ///   - value: The value to add to the cache. If nil, any existing information for that key is removed.
    ///   - key: The key to identify the cached value.
    public func set(_ value: Value?, for key: Key, expiresOn date: Date?) {
        guard let value = value else {
            keysOrderedByRecentUse.removeAll { $0 == key }
            backingStoreDictionary[key] = nil
            expirationDictionary[key] = nil
            return
        }
        
        if let index = keysOrderedByRecentUse.firstIndex(of: key) {
            moveKeyToFrontOfList(key: key, atIndex: index)
            backingStoreDictionary[key] = value
        } else {
            keysOrderedByRecentUse.insert(key, at: keysOrderedByRecentUse.startIndex)
            backingStoreDictionary[key] = value
        }
        
        expirationDictionary[key] = date
        
        if keysOrderedByRecentUse.count > capacity {
            if let leastRecentlyUsedKey = keysOrderedByRecentUse.popLast() {
                backingStoreDictionary[leastRecentlyUsedKey] = nil
            }
        }
    }
    
    /// Retrieves a value for the given key.
    ///
    /// - Parameter key: The key to retrieve a value for.
    /// - Returns: A value for the given key, or nil if the value was not found.
    public func value(for key: Key) -> Value? {
        guard let value = backingStoreDictionary[key] else {
            return nil
        }

        if let date = expirationDictionary[key], date < Date() {
            set(nil, for: key, expiresOn: nil)
            return nil
        }
        
        if let index = keysOrderedByRecentUse.firstIndex(of: key) {
            moveKeyToFrontOfList(key: key, atIndex: index)
        }
        
        return value
    }
    
    public subscript(key: Key) -> Value? {
        return value(for: key)
    }
    
    /// Removes all values from the cache.
    public func removeAllValues() {
        backingStoreDictionary.removeAll()
        keysOrderedByRecentUse.removeAll()
    }
    
    private func moveKeyToFrontOfList(key: Key, atIndex index: Int) {
        keysOrderedByRecentUse.remove(at: index)
        keysOrderedByRecentUse.insert(key, at: keysOrderedByRecentUse.startIndex)
    }
    
    @objc private func didReceiveMemoryWarning() {
        removeAllValues()
    }
}
