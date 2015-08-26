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
        
        LocalDataHandler.setData(["testKey": "testValue"], inFile: self.existingFile)
        LocalDataHandler.setData(nil, inFile: self.newFile)
    }
    
    func testDataIsAddedToNewFile() {
        let addedKey = "addedKey"
        assert(LocalDataHandler.setObject(404, forKey: addedKey, inFile: self.newFile), "Failed to set value for key")
        assert(LocalDataHandler.getObjectForKey(addedKey, fromFile: self.newFile) != nil, "Failed to retrieve value for added key in new file")
    }
    
    func testDataIsAddedToExistingFile() {
        let addedKey = "addedKey"
        assert(LocalDataHandler.setObject(404, forKey: addedKey, inFile: self.existingFile), "Failed to set value for key")
    }
    
    func testValuetIsReturnedForKeyInFile() {
        assert(LocalDataHandler.getObjectForKey("testKey", fromFile: self.existingFile) != nil, "Failed to retrieve value for key")
    }
    
    func testDataIsReturnedFile() {
        let keyValueData = LocalDataHandler.getDataFromFile(self.existingFile)
        assert(keyValueData.count == 1, "Failed to retrieve data from file. Count was \(keyValueData.count). Should have been 1")
        assert(keyValueData["testKey"] != nil, "Failed to retrieve data from file. Value for key was nil")
    }
    
    func testEmptyDictionaryIsReturnedForNonExistentFile() {
        let keyValueData = LocalDataHandler.getDataFromFile("nonExistentFile")
        assert(keyValueData.count == 0, "Dictionary for non-existent file was not empty")
    }
    
    func testNilReturnedForKeyInNonExistentFile() {
        let value: AnyObject? = LocalDataHandler.getObjectForKey("key", fromFile: "nonExistentFile")
        assert(value == nil, "Value for key in non-existent file was not nil")
    }
    
    func testNilReturnedForNonExistentKeyInFile() {
        let value: AnyObject? = LocalDataHandler.getObjectForKey("key", fromFile: self.existingFile)
        assert(value == nil, "Value for non-existent key in file was not nil")
    }
}