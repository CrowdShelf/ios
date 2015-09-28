//
//  CSRealmHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import RealmSwift


extension Realm {
    
//    MARK: Simplify reads
    
    class func read(block: ((Realm) -> AnyObject?), errorHandler: ((ErrorType)->Void)?) -> AnyObject? {
        do {
            let realm = try Realm()
            return block(realm)
        } catch let error as NSError {
            csprint(CS_DEBUG_REALM, "Failed to retrieve object(s) from Realm!\nError:", error.debugDescription)
            errorHandler?(error)
            return nil
        }
    }
    
    class func read(block: ((Realm) -> AnyObject?)) -> AnyObject? {
        return self.read(block, errorHandler: nil)
    }
    
//    MARK: Simplify write operations
    
    /// Write to the default realm
    class func write(block: ((Realm) -> Void), errorHandler: ((ErrorType)->Void)?) -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                block(realm)
            }
        } catch let error as NSError {
            csprint(CS_DEBUG_REALM, "Failed to write object(s) to Realm!\nError:", error.debugDescription)
            errorHandler?(error)
            return false
        }
        
        return true
    }
    
    /// Write to the default realm
    class func write(block: ((Realm) -> Void)) -> Bool {
        return self.write(block, errorHandler: nil)
    } 
}