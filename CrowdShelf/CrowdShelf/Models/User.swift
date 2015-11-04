//
//  CSUser.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

// FIXME: Ugly, temporary mimic of apples local user
private var _localUser : User?

public class User: BaseModel, Listable, Storeable {

    class var localUser : User? {
        get {
            return _localUser
        }
        set {
            _localUser = newValue
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.LocalUserUpdated, object: nil)
        }
    }
    
    
    dynamic var _id         : String?
    dynamic var name        : String?
    dynamic var email       : String?
    dynamic var username    : String?
    dynamic var token       : String?
    dynamic var password    : String?
    
    var image   : UIImage?
    var title   : String? { return username! }
    var subtitle: String? { return email }
    
    public var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }
    
        
    public override class func ignoreProperties() -> Set<String> {
        return ["image", "token", "title", "image", "subtitle"]
    }
    
    public class func primaryKey() -> String {
        return "_id"
    }
}


extension User {
    class func loginUser(user: User) {
        KeyValueHandler.setObject(user.serialize() , forKey: "user", inFile: LocalDataFile.User)
        self.localUser = user
    }
}