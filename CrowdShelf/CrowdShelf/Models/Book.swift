//
//  Book.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


/// A class representing a book
public class Book: BaseModel, Listable, Storeable {

    dynamic var _id                 : String?
    dynamic var isbn                : String?
    dynamic var owner               : String?
    dynamic var rentedTo            : String?
    dynamic var availableForRent    : Bool      = true
    
    dynamic var details : BookInformation?
    
    var title   : String? { return self.details?.title ?? "<no data>" }
    var image   : UIImage? { return self.details?.thumbnail }
    var subtitle: String?
    
    public var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }
    

    public override class func ignoreProperties() -> Set<String> {
        return ["details", "title", "image", "subtitle"]
    }
    
    public class func primaryKey() -> String {
        return "_id"
    }
}