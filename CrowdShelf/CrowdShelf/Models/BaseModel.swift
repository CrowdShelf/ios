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
    
    public init(dictionary: [String: AnyObject]) {
        super.init()
        
        for (key, value) in dictionary {
            if value is NSNull {
                continue
            }
            self.setValue(value, forKey: key)
        }
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

