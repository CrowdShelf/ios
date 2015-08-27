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

class CSCrowd {
    var name : String
    let creator: String
    var members : [String]
    
    
    /// The bare-bones workhorse of the crowd initalizers
    init(name: String, creator: String, members: [String]?) {
        self.name = name
        self.creator = creator
        self.members = members != nil ? members! : []
    }
    
    /// Useful when creating a new crowd
    convenience init(name: String) {
        self.init(name:     name,
                  creator:  "LocalUser",
                  members:  [])
    }
    
    /// Populate with data from a JSON object. Useful when communicating with the backend
    convenience init(json: JSON) {
        self.init(name:     json["name"].stringValue,
                  creator:  json["creator"].stringValue,
                  members:  json["members"].arrayObject as? [String])
    }
}