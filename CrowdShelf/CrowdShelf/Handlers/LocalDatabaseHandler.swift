//
//  FMDBHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 02/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation

private let _sharedInstance = LocalDatabaseHandler()

class Test: NSObject, Storeable {
    var string: String = "s"
    var int: NSNumber = 1
    var date: NSDate = NSDate()
    var array: [String] = ["1", "2", "3"]
    
    var ostring: String? = nil
    var oint: NSNumber? = nil
    var odate: NSDate? = nil
    
    class func primaryKey() -> String {
        return "string"
    }
}

class LocalDatabaseHandler: ObjectDatabase {
    
    class var sharedInstance : LocalDatabaseHandler {
        return _sharedInstance
    }
    
    init() {
        super.init(databaseName: "database")
        
        let t = Test()
        print(self.addObject(t))
//        let d = self.getObjectWithParameters(["string": "s"], forType: Test.self)
//        print(d)
    }
    
    /** Initialize the database with a table for each model */
    internal override func initializeDatabase() {
        self.createTableForType(Test.self)
        self.createTableForType(User.self)
        self.createTableForType(BookInformation.self)
        self.createTableForType(Book.self)
        self.createTableForType(Crowd.self)
    }
}