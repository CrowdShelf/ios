//
//  Book.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


/// A class representing a book
public class CSBook: CSBaseModel {

    dynamic var _id              = ""
    dynamic var _rev             = ""
    dynamic var isbn             = ""
    dynamic var owner            = ""
    dynamic var rentedTo         = ""
    
    dynamic var details : CSBookInformation?
    
    override public var description: String {
        if self.details != nil {
            return "\(self.owner)'s '\(self.details!.title)' with ISBN \(self.isbn)"
        }
        return "\(self.owner)'s book with ISBN \(self.isbn)"
    }
    
//    Realm Object
    
    override public class func primaryKey() -> String {
        return "_id"
    }
    
}