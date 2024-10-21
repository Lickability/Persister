//
//  SynchronizedArray.swift
//  Persister
//
//  Created by Twig on 2/7/23.
//  Copyright © 2023 Lickability. All rights reserved.
//

import Foundation

/// A Array-like collection that synchronizes access to its contents via GCD.
final class SynchronizedArray<Element: Equatable>: Sendable {
    private nonisolated(unsafe) var storage: [Element] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.lickability.synchronized-array")
        
    /// The count of the array.
    var count: Int {
        get {
            return queue.sync {
                return storage.count
            }
        }
    }

    /// Initializes an empty `SynchronizedArray`.
    init() { }
        
    /// Initializes a `SynchronizedArray` with the contents of the given array.
    /// - Parameter array: The array from which values are copied.
    init(_ array: [Element]) {
        self.storage = array
    }
    
    /// Returns the element for the provided index.
    subscript(index: Int) -> Element {
        set {
            queue.sync {
                storage[index] = newValue
            }
        }
        get {
            return queue.sync {
                return storage[index]
            }
        }
    }
    
    /// Appends a new element to the end of the array.
    /// - Parameter newElement: The element to append.
    func append(newElement: Element) {
        queue.sync {
            storage.append(newElement)
        }
    }
    
    /// Inserts the specified element at the front of the array.
    /// - Parameters:
    ///   - newElement: The element to insert.
    func insertAtFront(_ newElement: Element) {
        queue.sync {
            storage.insert(newElement, at: storage.startIndex)
        }
    }
    
    /// Removes and returns the last element of the collection.
    /// - Returns: The last element of the collection.
    func popLast() -> Element? {
        return queue.sync {
            return storage.popLast()
        }
    }
    
    /// Removes all elements from the array.
    func removeAll() {
        queue.sync {
            storage.removeAll()
        }
    }
    
    /// Removes all the elements that satisfy the given predicate.
    /// - Parameter shouldBeRemoved: A closure used to determine if an element should be removed.
    func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try queue.sync {
            try storage.removeAll(where: shouldBeRemoved)
        }
    }
    
    /// A function that determines if the array contains the provided element.
    /// - Parameter element: The element check to check for.
    /// - Returns: Returns a `Bool` signalling if the array contains the provided element.
    func contains(element: Element) -> Bool {
        return queue.sync {
            return storage.contains(element)
        }
    }
}
