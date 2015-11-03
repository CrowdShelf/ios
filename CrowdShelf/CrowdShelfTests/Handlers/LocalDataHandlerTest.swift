//
//  KeyValueHandlerTest.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import XCTest

@testable import CrowdShelf

class KeyValueHandlerTest: XCTestCase {

    let existingFile : String = "existingFile"
    let newFile : String = "newFile"
    
    override func setUp() {
        super.setUp()
        
        KeyValueHandler.setData(["testKey": "testValue"], inFile: self.existingFile)
        KeyValueHandler.setData(nil, inFile: self.newFile)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDataIsAddedToNewFile() {
        let addedKey = "addedKey"
        XCTAssert(KeyValueHandler.setObject(404, forKey: addedKey, inFile: self.newFile), "Failed to set value for key")
        XCTAssertNotNil(KeyValueHandler.getObjectForKey(addedKey, fromFile: self.newFile), "Failed to retrieve value for added key in new file")
    }
    
    func testDataIsAddedToExistingFile() {
        let addedKey = "addedKey"
        XCTAssert(KeyValueHandler.setObject(404, forKey: addedKey, inFile: self.existingFile), "Failed to set value for key")
        XCTAssertNotNil(KeyValueHandler.getObjectForKey(addedKey, fromFile: self.existingFile), "Failed to retrieve value for added key in existing file")
    }
    
    func testValuetIsReturnedForKeyInFile() {
        XCTAssertNotNil(KeyValueHandler.getObjectForKey("testKey", fromFile: self.existingFile), "Failed to retrieve value for key")
    }
    
    func testDataIsReturnedFile() {
        let keyValueData = KeyValueHandler.getDataFromFile(self.existingFile)
        XCTAssertEqual(keyValueData.count, 1, "Failed to retrieve data from file. Count was \(keyValueData.count). Should have been 1")
        XCTAssertNotNil(keyValueData["testKey"], "Failed to retrieve data from file. Value for key was nil")
    }
    
    func testEmptyDictionaryIsReturnedForNonExistentFile() {
        let keyValueData = KeyValueHandler.getDataFromFile("nonExistentFile")
        XCTAssertEqual(keyValueData.count, 0, "Dictionary for non-existent file was not empty")
    }
    
    func testNilReturnedForKeyInNonExistentFile() {
        let value: AnyObject? = KeyValueHandler.getObjectForKey("key", fromFile: "nonExistentFile")
        XCTAssertNil(value, "Value for key in non-existent file was not nil")
    }
    
    func testNilReturnedForNonExistentKeyInFile() {
        let value: AnyObject? = KeyValueHandler.getObjectForKey("key", fromFile: self.existingFile)
        XCTAssertNil(value, "Value for non-existent key in file was not nil")
    }
}