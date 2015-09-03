//
//  CSCrowd.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

// TODO: Default array should contain the local user

class CSCrowd: CSBaseModel, Listable {
    
    var id: String
    var name : String
    let creator: String
    var members : [String]
    
    
//    Listable
    @objc var title : String {
        return name
    }
    
    @objc var subtitle : String {
        return creator
    }
    
    
    
    /// The bare-bones workhorse of the crowd initalizers
    init(id: String, name: String, creator: String, members: [String]?) {
        self.id = id
        self.name = name
        self.creator = creator
        self.members = members != nil ? members! : [creator]
    }
    
    /// Useful when creating a new crowd
    convenience init(name: String, creator: String) {
        self.init(id:       "",
                  name:     name,
                  creator:  creator,
                  members:  [creator])
    }
    
    /// Populate with data from a JSON object. Useful when communicating with the backend
    required convenience init(json: JSON) {
        self.init(id:       json["id"].stringValue,
                  name:     json["name"].stringValue,
                  creator:  json["creator"].stringValue,
                  members:  json["members"].arrayObject as? [String])
    }
    
    
    
    
    
    override func toDictionary() -> [String : AnyObject] {
        return [
            "id": self.id,
            "name": self.name,
            "creator": self.creator,
            "members": self.members
        ]
    }
}