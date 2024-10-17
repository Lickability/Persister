//
//  PersisterTests.swift
//  PersisterTests
//
//  Created by Twig on 9/21/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import XCTest
@testable import Persister

final class PersisterTests: XCTestCase {

    private let diskURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    private let memoryCache = MemoryCache<TestCodable>(capacity: .unlimited, expirationPolicy: .never)
    private lazy var diskCache = DiskCache<TestCodable>(rootDirectoryURL: diskURL)
    private lazy var cache = Persister(memoryCache: memoryCache, diskCache: diskCache)

    override func tearDownWithError() throws {
        try cache.removeAll()
        
        try super.tearDownWithError()
    }
    
    func testWritingAndReadingItem() throws {
        let itemKey = "TestKey"
        
        try cache.write(item: TestCodable(), forKey: itemKey)
        
        let item: ItemContainer<TestCodable>? = try cache.read(forKey: itemKey)
        XCTAssertNotNil(item)
    }
    
    func testRemovingItem() throws {
        let itemKey = "TestKey"
        
        try cache.write(item: TestCodable(), forKey: itemKey)
        try cache.remove(forKey: itemKey)
                
        XCTAssertThrowsError(try { let _: ItemContainer<TestCodable>? = try self.cache.read(forKey: itemKey) }()) { error in
            guard case PersistenceError.noValidDataForKey = error else {
                return XCTFail()
            }
        }
    }
    
    func testRemovingAllItems() throws {
        let itemKey = "TestKey"
        let secondItemKey = "TestKey2"
        
        try cache.write(item: TestCodable(), forKey: itemKey)
        try cache.write(item: TestCodable(), forKey: secondItemKey)

        try cache.removeAll()
        
        XCTAssertThrowsError(try { let _: ItemContainer<TestCodable>? = try self.cache.read(forKey: itemKey) }()) { error in
            guard case PersistenceError.noValidDataForKey = error else {
                return XCTFail()
            }
        }
        
        XCTAssertThrowsError(try { let _: ItemContainer<TestCodable>? = try self.cache.read(forKey: secondItemKey) }()) { error in
            guard case PersistenceError.noValidDataForKey = error else {
                return XCTFail()
            }
        }
    }

    func testRemovingExpiredItems() throws {
        let expectation = XCTestExpectation(description: "Only one item should have been removed.")
        
        let itemKey = "TestKey"
        let secondItemKey = "TestKey2"
        
        let memoryCache = MemoryCache<TestCodable>(capacity: .unlimited, expirationPolicy: .afterInterval(1))
        let diskCache = DiskCache<TestCodable>(rootDirectoryURL: diskURL, expirationPolicy: .afterInterval(1))
        let cache = Persister<MemoryCache<TestCodable>, DiskCache<TestCodable>, TestCodable>(memoryCache: memoryCache, diskCache: diskCache)

        try cache.write(item: TestCodable(), forKey: itemKey)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            try? cache.write(item: TestCodable(), forKey: secondItemKey)
            
            try? cache.removeExpired()

            let item1: ItemContainer<TestCodable>? = try? cache.read(forKey: itemKey)
            let item2: ItemContainer<TestCodable>? = try? cache.read(forKey: secondItemKey)

            XCTAssertNil(item1)
            XCTAssertNotNil(item2)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
