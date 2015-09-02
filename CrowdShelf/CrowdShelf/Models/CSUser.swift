//
//  CSUser.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

// FIXME: Ugly, temporary mimic of apples local user
private var _localUser : CSUser? = CSUser(id: "ABFKAJEb432j#$jkb", emails: ["oyvindkg@yahoo.com"], name: "Øyvind Grimnes")

/// Dummy class until model is defined
class CSUser: CSBaseModel {
    
    let id: String?
    var emails: [String]
    var name: String
    
    class var localUser : CSUser? {
        get {
            return _localUser
        }
        set {
            _localUser = newValue
        }
    }
    
    init(id: String?, emails: [String], name: String) {
        self.id = id
        self.emails = emails
        self.name = name
        super.init()
    }
    
    convenience init(email: String, name: String) {
        self.init(id: nil, emails: [email], name: name)
    }
    
    convenience init(name: String) {
        self.init(id: nil, emails: [], name: name)
    }
    
    /// Populate with data from a JSON object. Useful when communicating with the backend
    convenience required init(json: JSON) {
        self.init(id:       json["id"].stringValue,
                  emails:   json["emails"].arrayObject as! [String],
                  name:     json["name"].stringValue)
    }
}