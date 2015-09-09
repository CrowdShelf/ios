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
    let owner: String
    var members : [CSUser]
    
    @objc var title : String { return name }
    @objc var subtitle : String { return owner }
    
    
    
    /// The bare-bones workhorse of the crowd initalizers
    init(id: String, name: String, owner: String, members: [CSUser]?) {
        self.id = id
        self.name = name
        self.owner = owner
        self.members = members ?? []
    }
    
    
    /**
    Create a new crowd instance with a provided creator
    
    :param:     name    name of the crowd
    :param:     creator username of the creator
    
    :returns:   A new crowd instance
    */
    
    convenience public init(name: String, owner: String) {
        self.init(id:       "-1",
                  name:     name,
                  owner:    owner,
                  members:  nil)
    }
    
    
    /**
    Create a new crowd instance populated with data from a JSON object. Useful when communicating with external systems
    
    :param:     json   json object containing data about a crowd
    
    :returns:   A new crowd instance
    */
    
    required convenience public init(json: JSON) {
        let members: [CSUser] = json["members"].arrayValue.map {CSUser(json: $0)}
        
        self.init(id:       json["_id"].stringValue,
                  name:     json["name"].stringValue,
                  owner:    json["owner"].stringValue,
                  members:  members)
    }
    
    
    /**
    Create a dictionary containing all information the instance contains
    
    :returns:   A dictionary containing all information the instance contains
    */
    
    override func toDictionary() -> [String : AnyObject] {
        return [
            "_id": self.id,
            "name": self.name,
            "owner": self.owner,
            "members": self.members
        ]
    }
}