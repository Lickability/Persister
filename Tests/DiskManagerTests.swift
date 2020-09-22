//
//  DiskManagerTests.swift
//  PersisterTests
//
//  Created by Twig on 9/21/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import XCTest
@testable import Persister

final class DiskManagerTests: XCTestCase {
        
    private let diskManager: DiskManager = FileManager.default
    private let diskURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    private lazy var path = diskURL.appendingPathComponent("TestPath").path
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try diskManager.createDirectoryIfNecessary(directoryURL: diskURL)
    }
    
    override func tearDownWithError() throws {
        try diskManager.removeContentsOfDirectory(at: diskURL)
        
        try super.tearDownWithError()
    }
    
    func testWritingAndReadingData() {
        diskManager.write(Data(), toPath: path, expiresOn: nil)
        
        XCTAssertNotNil(diskManager.read(atPath: path))
    }
    
    func testRemovingData() throws {
        diskManager.write(Data(), toPath: path, expiresOn: nil)
        try diskManager.remove(atPath: path)
        
        XCTAssertNil(diskManager.read(atPath: path))
    }
    
    func testRemovingAllDataInDirectory() throws {
        let secondPath = diskURL.appendingPathComponent("TestPath2").path
        
        diskManager.write(Data(), toPath: path, expiresOn: nil)
        diskManager.write(Data(), toPath: secondPath, expiresOn: nil)
        
        try diskManager.removeContentsOfDirectory(at: diskURL)
        
        XCTAssertNil(diskManager.read(atPath: path))
        XCTAssertNil(diskManager.read(atPath: secondPath))
    }
    
    func testRemovingExpiredContent() throws {
        let secondPath = diskURL.appendingPathComponent("TestPath2").path
        
        diskManager.write(Data(), toPath: path, expiresOn: Date().addingTimeInterval(-1))
        diskManager.write(Data(), toPath: secondPath, expiresOn: nil)
        
        try diskManager.removeExpiredContentsOfDirectory(at: diskURL)
        
        XCTAssertNil(diskManager.read(atPath: path))
        XCTAssertNotNil(diskManager.read(atPath: secondPath))
    }
}
