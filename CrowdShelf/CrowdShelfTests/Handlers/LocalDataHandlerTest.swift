//
//  LocalDataHandlerTest.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import XCTest

class LocalDataHandlerTest: XCTestCase {

    let existingFile : String = "existingFile"
    let newFile : String = "newFile"
    
    override func setUp() {
        super.setUp()
        
        LocalDataHandler.setData(["testKey": "testValue"], inFile: self.existingFile)
        LocalDataHandler.setData(nil, inFile: self.newFile)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDataIsAddedToNewFile() {
        let addedKey = "addedKey"
        XCTAssert(LocalDataHandler.setObject(404, forKey: addedKey, inFile: self.newFile), "Failed to set value for key")
        XCTAssertFalse(LocalDataHandler.getObjectForKey(addedKey, fromFile: self.newFile) == nil, "Failed to retrieve value for added key in new file")
    }
    
    func testDataIsAddedToExistingFile() {
        let addedKey = "addedKey"
        XCTAssert(LocalDataHandler.setObject(404, forKey: addedKey, inFile: self.existingFile), "Failed to set value for key")
        XCTAssertFalse(LocalDataHandler.getObjectForKey(addedKey, fromFile: self.existingFile) == nil, "Failed to retrieve value for added key in existing file")
    }
    
    func testValuetIsReturnedForKeyInFile() {
        XCTAssertFalse(LocalDataHandler.getObjectForKey("testKey", fromFile: self.existingFile) == nil, "Failed to retrieve value for key")
    }
    
    func testDataIsReturnedFile() {
        let keyValueData = LocalDataHandler.getDataFromFile(self.existingFile)
        XCTAssertEqual(keyValueData.count, 1, "Failed to retrieve data from file. Count was \(keyValueData.count). Should have been 1")
        XCTAssertFalse(keyValueData["testKey"] == nil, "Failed to retrieve data from file. Value for key was nil")
    }
    
    func testEmptyDictionaryIsReturnedForNonExistentFile() {
        let keyValueData = LocalDataHandler.getDataFromFile("nonExistentFile")
        XCTAssertEqual(keyValueData.count, 0, "Dictionary for non-existent file was not empty")
    }
    
    func testNilReturnedForKeyInNonExistentFile() {
        let value: AnyObject? = LocalDataHandler.getObjectForKey("key", fromFile: "nonExistentFile")
        XCTAssert(value == nil, "Value for key in non-existent file was not nil")
    }
    
    func testNilReturnedForNonExistentKeyInFile() {
        let value: AnyObject? = LocalDataHandler.getObjectForKey("key", fromFile: self.existingFile)
        XCTAssert(value == nil, "Value for non-existent key in file was not nil")
    }
}