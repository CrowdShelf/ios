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
    var subtitle    : String? { return owner }
    var image       : UIImage?
    
    var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }

}

extension Crowd {
    class var columnDefinitions: [String: [String]] {
        return [
            "_id"       : ["TEXT", "PRIMARY KEY"],
            "name"      : ["TEXT", "NOT NULL"],
            "owner"     : ["TEXT", "NOT NULL"],
            "members"   : ["TEXT", "NOT NULL"]
        ]
    }
}