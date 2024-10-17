//
//  MemoryCacheTests.swift
//  PersisterTests
//
//  Created by Twig on 9/21/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import XCTest
@testable import Persister

final class MemoryCacheTests: XCTestCase {

    private let cache = MemoryCache<TestCodable>(capacity: .unlimited, expirationPolicy: .never)
    private let itemKey = "TestKey"
    private let secondItemKey = "TestKey2"

    override func tearDownWithError() throws {
        try cache.removeAll()
        
        try super.tearDownWithError()
    }
    
    func testWritingAndReadingItem() throws {
        try cache.write(item: TestCodable(), forKey: itemKey)
        
        let item: ItemContainer<TestCodable>? = try cache.read(forKey: itemKey)
        XCTAssertNotNil(item)
    }
    
    func testRemovingItem() throws {
        try cache.write(item: TestCodable(), forKey: itemKey)
        try cache.remove(forKey: itemKey)
        
        let item: ItemContainer<TestCodable>? = try cache.read(forKey: itemKey)
        XCTAssertNil(item)
    }
    
    func testRemovingAllItems() throws {
        try cache.write(item: TestCodable(), forKey: itemKey)
        try cache.write(item: TestCodable(), forKey: secondItemKey)

        try cache.removeAll()
        
        let item1: ItemContainer<TestCodable>? = try cache.read(forKey: itemKey)
        let item2: ItemContainer<TestCodable>? = try cache.read(forKey: secondItemKey)

        XCTAssertNil(item1)
        XCTAssertNil(item2)
    }
    
    func testRemovingExpiredItems() throws {
        let expectation = XCTestExpectation(description: "Only one item should have been removed.")
        
        let cache = MemoryCache<TestCodable>(capacity: .unlimited, expirationPolicy: .afterInterval(1))
        try cache.write(item: TestCodable(), forKey: itemKey)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            try? cache.write(item: TestCodable(), forKey: self.secondItemKey)
            
            try? cache.removeExpired()

            let item1: ItemContainer<TestCodable>? = try? cache.read(forKey: self.itemKey)
            let item2: ItemContainer<TestCodable>? = try? cache.read(forKey: self.secondItemKey)

            XCTAssertNil(item1)
            XCTAssertNotNil(item2)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testCacheLimit() throws {
        let cache = MemoryCache<TestCodable>(capacity: .limited(numberOfItems: 3), expirationPolicy: .never)
        
        try cache.write(item: TestCodable(), forKey: "1")
        try cache.write(item: TestCodable(), forKey: "2")
        try cache.write(item: TestCodable(), forKey: "3")
        try cache.write(item: TestCodable(), forKey: "4")
        
        let item1: ItemContainer<TestCodable>? = try cache.read(forKey: "1")
        let item2: ItemContainer<TestCodable>? = try cache.read(forKey: "2")
        let item3: ItemContainer<TestCodable>? = try cache.read(forKey: "3")
        let item4: ItemContainer<TestCodable>? = try cache.read(forKey: "4")

        XCTAssertNil(item1)
        XCTAssertNotNil(item2)
        XCTAssertNotNil(item3)
        XCTAssertNotNil(item4)
    }
    
    func testUsesCorrectExpirationPolicy() throws {
        let expectation = XCTestExpectation(description: "Only one item should have been removed.")
        
        let cache = MemoryCache<TestCodable>(capacity: .unlimited, expirationPolicy: .afterInterval(1))
        try cache.write(item: TestCodable(), forKey: itemKey, expirationPolicy: .afterInterval(500))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            try? cache.removeExpired()
            
            let item1: ItemContainer<TestCodable>? = try? cache.read(forKey: self.itemKey)
            
            XCTAssertNotNil(item1)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
