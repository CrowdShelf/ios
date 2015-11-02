//
//  Crowd.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

/// A class representing a crowd
public class Crowd: BaseModel, Listable, Collectable, Storeable {
    
    dynamic var _id     = ""
    dynamic var name    = ""
    dynamic var owner   = ""
    var members         = [String]()
    
    @objc var title : String { return name }
    @objc var subtitle : String? { return owner }
    var image: UIImage?
    
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