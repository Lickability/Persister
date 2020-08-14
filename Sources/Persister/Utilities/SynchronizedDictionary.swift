//
//  SynchronizedDictionary.swift
//  Persister
//
//  Created by Grant Butler on 1/18/18.
//  Copyright © 2018 Lickability. All rights reserved.
//

import Foundation

/// A Dictionary-like collection that synchronizes access to its contents via GCD.
final class SynchronizedDictionary<Key, Value> where Key: Hashable {
    private var storage: [Key: Value] = [:]
    private let queue: DispatchQueue = DispatchQueue(label: "com.lickability.synchronized-dictionary", attributes: [.concurrent])
    
    /// Initializes an empty `SynchronizedDictionary`.
    init() { }
    
    /// Initializes a `SynchronizedDictionary` with the contents of the given dictionary.
    ///
    /// - Parameter dictionary: The dictionary from which key-value pairs are copied.
    init(_ dictionary: [Key: Value]) {
        self.storage = dictionary
    }
}

extension SynchronizedDictionary: Sequence {
    
    // MARK: - Sequence
    
    func makeIterator() -> DictionaryIterator<Key, Value> {
        return queue.sync {
            return storage.makeIterator()
        }
    }
}

extension SynchronizedDictionary {
    
    /// A collection containing just the values of the dictionary.
    var values: Dictionary<Key, Value>.Values {
        return queue.sync {
            return storage.values
        }
    }
    
    /// A collection containing just the keys of the dictionary.
    var keys: Dictionary<Key, Value>.Keys {
        return queue.sync {
            return storage.keys
        }
    }
    
    /// Removes the given key and its associated value from the dictionary and returns it if it was found.
    ///
    /// - Parameter key: The key to remove along with its associated value.
    @discardableResult func removeValue(forKey key: Key) -> Value? {
        return queue.sync {
            return storage.removeValue(forKey: key)
        }
    }
    
    func removeAll() {
        queue.sync {
            storage.removeAll()
        }
    }
}

extension SynchronizedDictionary {
    
    /// Accesses the value associated with the given key for reading and writing. Returns `nil` if not found.
    /// - Parameter key: The key to find in the dictionary.
    subscript(key: Key) -> Value? {
        get {
            return queue.sync {
                return storage[key]
            }
        }
        set(newValue) {
            queue.async(flags: [.barrier]) {
                self.storage[key] = newValue
            }
        }
    }
}
