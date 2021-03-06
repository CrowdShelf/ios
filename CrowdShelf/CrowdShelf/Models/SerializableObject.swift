//
//  SerializableObject.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 21/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//


/** 
 JSON:      a hierarchical dictionary containing valid JSON data types.

 SQLite:    a flat dictionary containing Cocoa classes
*/
public enum SerializationMode {
    case JSON, SQLite
}

public class SerializableObject: NSObject {
    
    /**
    Serialize the object
    
    - returns:              A dictionary containing the data from the object
    */
    
    public func serialize() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        let mirror = Mirror(reflecting: self)
        
        for (key, child) in mirror.children {
            if key == nil || (mirror.subjectType as! SerializableObject.Type).ignoreProperties().contains(key!) {
                continue
            }
                        
            var propertyValue: AnyObject? = SerializableObject.serializedValueForProperty(key!)
            
            if propertyValue == nil {
                if let value = self.unwrap(child) as? AnyObject {
                    propertyValue = value
                    
                    /* Convert data to string and dates to timestamps for JSON */
                    if let serializableValue = value as? SerializableObject {
                        propertyValue = serializableValue.serialize()
                    } else if let arrayValue = value as? [SerializableObject] {
                        propertyValue = arrayValue.map {$0.serialize()}
                    } else if let dataValue = value as? NSData {
                        propertyValue = dataValue.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                    } else if let dateValue = value as? NSDate {
                        propertyValue = dateValue.timeIntervalSince1970
                    }
                }
            }
            
            dictionary[key!] = propertyValue ?? NSNull()
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
    
    class func serializedValueForProperty(property: String) -> AnyObject? {
        return nil
    }
    
    class public func ignoreProperties() -> Set<String> {
        return []
    }
}