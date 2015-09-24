//
//  CSUser.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import RealmSwift

// FIXME: Ugly, temporary mimic of apples local user
private var _localUser : CSUser?

public class CSUser: CSBaseModel {

    dynamic var _id         = ""
    dynamic var name        = ""
    dynamic var email       = ""
    dynamic var username    = ""
    
    /// The user that is currently authenticated
    class var localUser : CSUser? {
        get {
            return _localUser
        }
        set {
            _localUser = newValue
            NSNotificationCenter.defaultCenter().postNotificationName(CSNotification.LocalUserUpdated, object: nil)
        }
    }
    
//    MARK: Realm Object
    
    override public class func primaryKey() -> String {
        return "username"
    }

}