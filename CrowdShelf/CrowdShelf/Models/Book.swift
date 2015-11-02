//
//  Book.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


/// A class representing a book
public class Book: BaseModel, Collectable, Storeable {

    dynamic var _id                 : String?
    dynamic var isbn                : String?
    dynamic var owner               : String?
    dynamic var rentedTo            : String?
    dynamic var availableForRent    : Bool      = true
    
    dynamic var details : BookInformation?
    
    var title: String { return self.details?.title ?? "<no data>" }
    var image: UIImage? { return self.details?.thumbnail }
    var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }
    
    public override var description: String {
        return self.serialize().description
    }
    
//    Serializable Object
    public override func ignoreProperties() -> Set<String> {
        return ["details"]
    }
}

extension Book {
    class var columnDefinitions: [String: [String]] {
        return [
            "_id"               : ["TEXT", "PRIMARY KEY"],
            "isbn"              : ["TEXT", "NOT NULL"],
            "availableForRent"  : ["BOOL", "DEFAULT 1"],
            "owner"             : ["TEXT", "NOT NULL"],
            "rentedTo"          : ["TEXT"],
        ]
    }
}