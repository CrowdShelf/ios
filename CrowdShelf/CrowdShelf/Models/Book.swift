//
//  Book.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


/// A class representing a book
public class Book: BaseModel {

    dynamic var _id              = "-1"
    dynamic var isbn             = ""
    dynamic var owner            = ""
    dynamic var rentedTo         = ""
    dynamic var availableForRent = true
    
    dynamic var details : BookInformation?
    
    public override var description: String {
        return self.serialize().description
    }

//    Realm Object
    
    override public class func primaryKey() -> String {
        return "_id"
    }
    
//    Serializable Object
    
    public override func ignoreProperties() -> Set<String> {
        return ["details"]
    }
    
    override func serializedValueForProperty(property: String) -> AnyObject? {
        if property == "rentedTo" {
            return self.rentedTo == "" ? NSNull() : self.rentedTo
        }
        
        return nil
    }
}