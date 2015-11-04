//
//  Crowd.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

/// A class representing a crowd
public class Crowd: BaseModel, Listable, Storeable {
    
    dynamic var _id     : String?
    dynamic var name    : String?
    dynamic var owner   : String?
    dynamic var members : [String] = []
    
    var title       : String? { return name }
    var subtitle    : String? { return "\(members.count) members" }
    var image       : UIImage?
    
    public var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }
    
    public override class func ignoreProperties() -> Set<String> {
        return ["image", "title", "image", "subtitle"]
    }
    
    public class func primaryKey() -> String {
        return "_id"
    }
}