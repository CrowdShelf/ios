//
//  CSCrowd.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A class representing a crowd
public class CSCrowd: CSBaseModel, Listable {
    
    var id: String
    var name : String
    let creator: String
    var members : [String]
    
    @objc var title : String { return name }
    @objc var subtitle : String { return creator }
    
    
    
    /// The bare-bones workhorse of the crowd initalizers
    init(id: String, name: String, creator: String, members: [String]?) {
        self.id = id
        self.name = name
        self.creator = creator
        self.members = members != nil ? members! : [creator]
    }
    
    
    /**
    Create a new crowd instance with a provided creator
    
    :param:     name    name of the crowd
    :param:     creator username of the creator
    
    :returns:   A new crowd instance
    */
    
    convenience public init(name: String, creator: String) {
        self.init(id:       "",
                  name:     name,
                  creator:  creator,
                  members:  [creator])
    }
    
    
    /**
    Create a new crowd instance populated with data from a JSON object. Useful when communicating with external systems
    
    :param:     json   json object containing data about a crowd
    
    :returns:   A new crowd instance
    */
    
    required convenience public init(json: JSON) {
        self.init(id:       json["id"].stringValue,
                  name:     json["name"].stringValue,
                  creator:  json["creator"].stringValue,
                  members:  json["members"].arrayObject as? [String])
    }
    
    
    /**
    Create a dictionary containing all information the instance contains
    
    :returns:   A dictionary containing all information the instance contains
    */
    
    override func toDictionary() -> [String : AnyObject] {
        return [
            "id": self.id,
            "name": self.name,
            "creator": self.creator,
            "members": self.members
        ]
    }
}