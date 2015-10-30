//
//  CSUser.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import RealmSwift

// FIXME: Ugly, temporary mimic of apples local user
private var _localUser : User?

public class User: BaseModel, Listable {

    dynamic var _id         = ""
    dynamic var name        = ""
    dynamic var email       = ""
    dynamic var username    = ""
    dynamic var token       = ""
    
    var image: UIImage?
    
    /// The user that is currently authenticated
    class var localUser : User? {
        get {
            return _localUser
        }
        set {
            _localUser = newValue
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.LocalUserUpdated, object: nil)
        }
    }
    
    var title: String { return username }
    var subtitle: String? { return email }
    
//    MARK: Realm Object
    
    public override func ignoreProperties() -> Set<String> {
        return ["image", "token"]
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    override public class func primaryKey() -> String {
        return "_id"
    }
}


extension User {
    class func loginUser(user: User) {
        LocalDataHandler.setObject(user.serialize() , forKey: "user", inFile: LocalDataFile.User)
        self.localUser = user
    }
}