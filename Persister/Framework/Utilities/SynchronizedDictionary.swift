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
    fileprivate var storage: [Key: Value] = [:]
    fileprivate let queue: DispatchQueue = DispatchQueue(label: "com.lickability.synchronized-dictionary", attributes: [.concurrent])
    
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

// We explicitly don’t conform to `Swift.Collection` because `Swift.Collection`
// makes certain requirements that are difficult to fulfill when we want just a
// simple wrapper around `Dictionary`. To meet said requirements, we'd have to
// implement a number of new types, rather than being able to reuse existing
// `Dictionary` types like we are in this implementation. As a result, we don't
// conform to `Swift.Collection` and instead explicitly implement methods and
// properties that `Swift.Collection` would have given us for free.
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
    
    /// Removes the given key and its associated value from the dictionary.
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or `nil` if the key was not present in the dictionary.
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
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with `key` if `key` is in the dictionary; otherwise, `nil`.
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
