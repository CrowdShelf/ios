//
//  SerializableObject.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 21/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import RealmSwift

public class SerializableObject: Object {
    
    /**
    Serialize the object
    
    - returns:              An object representing the object
    */
    
    public func serialize() -> AnyObject {
        var dictionary: [String: AnyObject] = [:]
        let mirror = Mirror(reflecting: self)
        
        for (key, child) in mirror.children {
            if key == nil {
                continue
            }
            
            var propertyValue: AnyObject? = self.serializedValueForProperty(key!)
            
            if propertyValue == nil {
                if let value = self.unwrap(child) as? AnyObject {
                    
                    if let serializableValue = value as? SerializableObject {
                        propertyValue = serializableValue.serialize()
                    } else if let arrayValue = value as? [SerializableObject] {
                        propertyValue = arrayValue.map {$0.serialize()}
                    }
                    
                    else if let dataValue = value as? NSData {
                        propertyValue = dataValue.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                    } else if let dateValue = value as? NSDate {
                        propertyValue = dateValue.timeIntervalSince1970
                    } else {
                        propertyValue = value
                    }
                }
            }
            
            dictionary[key!] = propertyValue
        }
        
        return dictionary
    }
    
    /** 
    
    Unwraps any optional values

    - parameter value:  The value to unwrap

    */
    
    private func unwrap(value: Any) -> Any? {
        let mi = Mirror(reflecting: value)
        
        if mi.displayStyle != .Optional {
            return value
        }
        
        if mi.children.count == 0 {
            return nil
        }
        
        let (_, some) = mi.children.first!
        
        return some
    }
    
    /**
    Used to customize the serialization of an objects properties. Can be overridden in subclasses
    
    - parameter property:   The name of a property
    
    - returns:              An optional custom serialized object
    */
    
    func serializedValueForProperty(property: String) -> AnyObject? {
        return nil
    }
}