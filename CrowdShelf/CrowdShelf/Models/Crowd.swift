//
//  Crowd.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import RealmSwift

/// A class representing a crowd
public class Crowd: BaseModel, Listable, Collectable {
    
    dynamic var _id     = ""
    dynamic var name    = ""
    dynamic var owner   = ""
    var members         = List<RLMWrapper>()
    
    @objc var title : String { return name }
    @objc var subtitle : String? { return owner }
    var image: UIImage?
    
//    MARK: Realm Object
    
    override public static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    override public class func primaryKey() -> String {
        return "_id"
    }
}