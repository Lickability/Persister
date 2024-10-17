//
//  DiskCacheTests.swift
//  PersisterTests
//
//  Created by Twig on 9/21/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import XCTest
@testable import Persister

final class DiskCacheTests: XCTestCase {

    private lazy var cache = DiskCache<TestCodable>(rootDirectoryURL: diskURL)
    private let diskURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

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
        
        let cache = DiskCache<TestCodable>(rootDirectoryURL: diskURL, expirationPolicy: .afterInterval(1))
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
    
//    func testDecodingFailureError() throws {
//    let itemKey = "TestKey"
//        try cache.write(item: TestCodable(), forKey: itemKey)
//                
//        XCTAssertThrowsError(try { let _: ItemContainer<String>? = try self.cache.read(forKey: self.itemKey) }()) { error in
//            guard case PersistenceError.decodingError = error else {
//                return XCTFail()
//            }
//        }
//    }
    
    func testUsesCorrectExpirationPolicy() throws {
        let expectation = XCTestExpectation(description: "Only one item should have been removed.")
        
        let itemKey = "TestKey"
        
        let cache = DiskCache<TestCodable>(rootDirectoryURL: diskURL, expirationPolicy: .afterInterval(1))
        try cache.write(item: TestCodable(), forKey: itemKey, expirationPolicy: .afterInterval(500))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         
            try? cache.removeExpired()
            
            let item1: ItemContainer<TestCodable>? = try? cache.read(forKey: itemKey)
                        
            XCTAssertNotNil(item1)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
