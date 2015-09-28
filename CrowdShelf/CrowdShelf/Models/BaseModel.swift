//
//  CSBaseModel.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

/// The base model which all other data models extends
public class BaseModel: SerializableObject {
    
// Override value initializers to make the values compatible with Realm
    
    required public init() {
        super.init()
    }
    
    override init(value: AnyObject) {
        if let dictionary = value as? [String: AnyObject] {
            super.init(value: BaseModel.dictionaryWithoutNSNull(dictionary))
        } else {
            super.init(value: value)
        }
    }
    
    override init(value: AnyObject, schema: RLMSchema) {
        if let dictionary = value as? [String: AnyObject] {
            super.init(value: BaseModel.dictionaryWithoutNSNull(dictionary), schema: schema)
        } else {
            super.init(value: value, schema: schema)
        }
    }
    
    override init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    private class func dictionaryWithoutNSNull(dictionary: [String: AnyObject]) -> [String: AnyObject] {
        var valueDictionary = dictionary
        
        for key in valueDictionary.keys {
            if valueDictionary[key] is NSNull {
                valueDictionary.removeValueForKey(key)
            }
        }
        
        return valueDictionary
    }
}

