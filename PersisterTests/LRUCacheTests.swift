//
//  LRUCacheTests.swift
//  PersisterTests
//
//  Created by Twig on 5/30/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import XCTest
@testable import Persister

class LRUCacheTests: XCTestCase {
    
    private let cache = LRUCache<String, String>(capacity: 100)
    
    override func tearDown() {
        cache.removeAllItems()
        
        super.tearDown()
    }
    
    func testCacheReturnsStoredValue() {
        let value = "value"
        let key = "key"
        
        cache.set(value, for: key, expiresOn: nil)
        XCTAssertEqual(value, cache.read(for: key))
    }
    
    func testLRUEvictsObject() {
        let cache = LRUCache<String, String>(capacity: 3)
        
        cache.set("1", for: "1", expiresOn: nil)
        cache.set("2", for: "2", expiresOn: nil)
        cache.set("3", for: "3", expiresOn: nil)
        cache.set("4", for: "4", expiresOn: nil)
        
        XCTAssertNil(cache.read(for: "1"))
    }
    
    func testLRUResetsObjectToHeadWhenAccessed() {
        let cache = LRUCache<String, String>(capacity: 3)
        
        cache.set("1", for: "1", expiresOn: nil)
        cache.set("2", for: "2", expiresOn: nil)
        cache.set("3", for: "3", expiresOn: nil)
        _ = cache.read(for: "1")
        
        cache.set("4", for: "4", expiresOn: nil)
        
        XCTAssertNil(cache.read(for: "2"))
        XCTAssertNotNil(cache.read(for: "1"))
    }
    
    func testCacheWritePerformance() {
        let cache = LRUCache<Int, String>(capacity: 100)
        
        measure {
            for x in 1...1000 {
                cache.set("value", for: x, expiresOn: nil)
            }
        }
    }
    
    func testCacheReadPerformance() {
        let key = "key"

        cache.set("value", for: key, expiresOn: nil)

        measure {
            for _ in 1...1000 {
                _ = cache.read(for: key)
            }
        }
    }
}
