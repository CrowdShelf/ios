//
//  RLMWrapperObject.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 21/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import RealmSwift
import Realm


/**

A wrapper object used to wrap values not compatible with Realm

*/

class RLMWrapper: Object, StringLiteralConvertible {
    dynamic var content: AnyObject = ""
    
    var stringValue: String? {
        return self.content as? String
    }
    
    var integerValue: Int? {
        return self.content as? Int
    }
    
    var floatValue: Float? {
        return self.content as? Float
    }
    
//    MARK: Realm Object
    
    init(_ content: AnyObject) {
        self.content = content
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    override init(value: AnyObject) {
        super.init(value: ["content": value])
    }
    
    override init(value: AnyObject, schema: RLMSchema) {
        super.init(value: ["content": value], schema: schema)
    }
    
    override init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    internal required init(unicodeScalarLiteral value: String) {
        super.init(value: ["content": value])
    }

    internal required init(extendedGraphemeClusterLiteral value: String) {
        super.init(value: ["content": value])
    }
    
    required internal init(stringLiteral value: String) {
        super.init(value: ["content": value])
    }
}