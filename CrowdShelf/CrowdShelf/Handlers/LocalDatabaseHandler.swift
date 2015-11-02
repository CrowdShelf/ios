//
//  FMDBHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 02/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import UIKit

private let _sharedInstance = LocalDatabaseHandler()


class LocalDatabaseHandler: ObjectDatabase {
    
    class var sharedInstance : LocalDatabaseHandler {
        return _sharedInstance
    }
    
    init() {
        super.init(databaseName: "database")
    }
    
    /** Initialize the database with a table for each model */
    internal override func initializeDatabase() {
        self.createTableForType(User.self)
        self.createTableForType(BookInformation.self)
        self.createTableForType(Book.self)
        self.createTableForType(Crowd.self)
    }
}