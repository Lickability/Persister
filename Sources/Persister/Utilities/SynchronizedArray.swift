//
//  SynchronizedArray.swift
//  Persister
//
//  Created by Twig on 2/7/23.
//  Copyright © 2023 Lickability. All rights reserved.
//

import Foundation

/// A Array-like collection that synchronizes access to its contents via GCD.
final class SynchronizedArray<Element: Equatable> {
    private var storage: [Element] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.lickability.synchronized-array")
    
    /// The starting index of the array.
    var startIndex: Int {
        get {
            var index: Int!

            queue.sync {
                index = storage.startIndex
            }
            
            return index
        }
    }
    
    /// The count of the array.
    var count: Int {
        get {
            var count: Int!

            queue.sync {
                count = storage.count
            }
            
            return count
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
            var element: Element!
            
            queue.sync {
                element = storage[index]
            }
            
            return element
        }
    }
    
    /// The first index of the provided element.
    /// - Parameter element: The element to find the index of.
    /// - Returns: The index of the element, if it exists within the array.
    func firstIndex(of element: Element) -> Array.Index? {
        var index: Int?
        
        queue.sync {
            index = storage.firstIndex(of: element)
        }
        
        return index
    }
    
    /// Appends a new element to the end of the array.
    /// - Parameter newElement: The element to append.
    func append(newElement: Element) {
        queue.sync {
            storage.append(newElement)
        }
    }
    
    /// Inserts the specified element at the index.
    /// - Parameters:
    ///   - newElement: The element to insert.
    ///   - index: The index to insert at.
    func insert(_ newElement: Element, at index: Int) {
        queue.sync {
            storage.insert(newElement, at: index)
        }
    }
    
    /// Removes and returns the last element of the collection.
    /// - Returns: The last element of the collection.
    func popLast() -> Element? {
        var element: Element?
        
        queue.sync {
            element = storage.popLast()
        }
        
        return element
    }
    
    
    /// Removes and returns the element at the specified position.
    /// - Parameter index: The index of the element to remove.
    /// - Returns: The element that was removed.
    @discardableResult
    func remove(at index: Int) -> Element {
        var element: Element!

        queue.sync {
            element = storage.remove(at: index)
        }
        
        return element
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
}
