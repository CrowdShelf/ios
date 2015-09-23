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

    dynamic var _id              = "\(arc4random())"
    dynamic var _rev             = ""
    dynamic var isbn             = ""
    dynamic var owner            = ""
    dynamic var rentedTo         = ""
    dynamic var avaliableForRent = true
    
    dynamic var details : CSBookInformation?
    
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
}