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
    private let memoryCache: Cache = MemoryCache(capacity: .unlimited, expirationPolicy: .never)
    private lazy var diskCache: Cache = DiskCache(rootDirectoryURL: diskURL)
    private lazy var cache: Cache = Persister(memoryCache: memoryCache, diskCache: diskCache)
    
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
                
        XCTAssertThrowsError(try { let _: ItemContainer<TestCodable>? = try self.cache.read(forKey: self.itemKey) }()) { error in
            guard case PersistenceError.noValidDataForKey = error else {
                return XCTFail()
            }
        }
    }
    
    func testRemovingAllItems() throws {
        try cache.write(item: TestCodable(), forKey: itemKey)
        try cache.write(item: TestCodable(), forKey: secondItemKey)

        try cache.removeAll()
        
        XCTAssertThrowsError(try { let _: ItemContainer<TestCodable>? = try self.cache.read(forKey: self.itemKey) }()) { error in
            guard case PersistenceError.noValidDataForKey = error else {
                return XCTFail()
            }
        }
        
        XCTAssertThrowsError(try { let _: ItemContainer<TestCodable>? = try self.cache.read(forKey: self.secondItemKey) }()) { error in
            guard case PersistenceError.noValidDataForKey = error else {
                return XCTFail()
            }
        }
    }

    func testRemovingExpiredItems() throws {
        let expectation = XCTestExpectation(description: "Only one item should have been removed.")
        
        let memoryCache: Cache = MemoryCache(capacity: .unlimited, expirationPolicy: .afterInterval(1))
        let diskCache: Cache = DiskCache(rootDirectoryURL: diskURL, expirationPolicy: .afterInterval(1))
        let cache: Cache = Persister(memoryCache: memoryCache, diskCache: diskCache)

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
}
