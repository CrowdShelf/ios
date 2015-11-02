//
//  CSBaseModel.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation

/// The base model which all other data models extends
public class BaseModel: SerializableObject {
    
    override init() {
        super.init()
    }
    
    convenience init(value: [String: AnyObject]) {
        self.init()
        
        for (key, value) in value {
            if value is NSNull {
                continue
            }
            self.setValue(value, forKey: key)
        }
        
        print("ok")
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

