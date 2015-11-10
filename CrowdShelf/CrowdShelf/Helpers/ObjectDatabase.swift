//
//  ObjectDatabase.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 03/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//


import Foundation


@objc public protocol Storeable {
    optional static func primaryKey() -> String
    optional static func ignoredProperties() -> Set<String>
}

public class ObjectDatabase {
    
    private let databaseQueue : FMDatabaseQueue

    
    public init(databaseName: String) {
        let documentsDir : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let databasePath = documentsDir+"/\(databaseName).sqlite"
        
//        try! NSFileManager.defaultManager().removeItemAtPath(databasePath)
        
        let shouldCreateDatabase = !NSFileManager.defaultManager().fileExistsAtPath(databasePath)
        
        self.databaseQueue = FMDatabaseQueue(path: databasePath)
        
        /* Initialize a new database if it did not exist */
        if shouldCreateDatabase {
            self.initializeDatabase()
        }
    }
    
    internal func initializeDatabase() {}
    
    
    
    /**
     Creates a new table for the specified type based on the provided column definitions
     
     - parameter type:              type of objects data in the table represents
     
     - returns:                     boolean indicating the success of the operation
     */
    
    public func createTableForType <T where T: NSObject, T: Storeable> (type: T.Type) -> Bool {
        
        let object = type.init()
        let mirror = Mirror(reflecting: object)
        
        /* Strings defining the columns of the table */
        var columnStrings: [String] = []
        
        for (key, child) in mirror.children {
            if key == nil || type.ignoredProperties?().contains(key!) ?? false {
                continue
            }
            
            /* The name, data type and properties of the column */
            var segments = [key!]
            
            let childMirror = Mirror(reflecting: child)
            
            let isOptional = childMirror.displayStyle == .Optional
            let childType: Any.Type = childMirror.subjectType
            
            if isOptional {
                switch childType {
                case is (String?).Type, is (NSDate?).Type, is (Array<String>?).Type:
                    segments.append("TEXT")
                case is (Bool?).Type:
                    segments.append("INT")
                case is (NSNumber?).Type:
                    segments.append("REAL")
                case is (NSData?).Type:
                    segments.append("BLOB")
                default:
                    continue
                }
            } else {
                switch childType {
                case is String.Type, is NSDate.Type, is Array<String>.Type:
                    segments.append("TEXT")
                case is Bool.Type:
                    segments.append("INT")
                case is NSNumber.Type:
                    segments.append("REAL")
                case is NSData.Type:
                    segments.append("BLOB")
                default:
                    continue
                }
            }
            
            if !isOptional {
                segments.append("NOT NULL")
            }
            
            if key == type.primaryKey?() {
                segments.append("PRIMARY KEY")
            }
            
            
            columnStrings.append(segments.joinWithSeparator(" "))
        }

        let tableName =  tableNameForType(T.self)
        let sql = "CREATE TABLE \(tableName) (\(columnStrings.joinWithSeparator(", ")))"

        return self.exequteStatement(sql)
    }
    
    
    
    
    /**
     Add an object of a specified type, represented by a dictionary, to the database
     
     - parameter object:     a dictionary containing the data form the object to be added
     - parameter type:       the type of the object to be added
     
     - returns:              boolean indicating the success of the request
     */
    
    public func addObject <T where T: NSObject, T: Storeable> (object: T, update: Bool = true) -> Bool {
        let validData     = storeableDataFromObject(object)
        
        let sql = insertObjectStatement(validData, type: T.self, update: update)
        
        return self.exequteStatement(sql, parameters: validData)
    }
    
    public func addObjects <T where T: NSObject, T: Storeable> (objects: [T], update: Bool = true) {
        for object in objects {
            let validData   = storeableDataFromObject(object)
            let sql         = insertObjectStatement(validData, type: T.self, update: update)
            self.exequteStatement(sql, parameters: validData)
        }
    }
    
    private func insertObjectStatement <T where T: NSObject, T: Storeable> (data: [String: AnyObject], type: T.Type, update: Bool = true) -> String {
        let valuesString    = data.keys.sort().map {":\($0)"}.joinWithSeparator(", ")
        let keysString      = data.keys.sort().map {"\($0)"}.joinWithSeparator(", ")
        let tableName       = tableNameForType(T.self)
        
        let method          = update ? "INSERT OR REPLACE " : "INSERT "
        
        return method + " INTO \(tableName) (\(keysString)) VALUES (\(valuesString))"
    }
    
    
    /**
     Remove objects of a specified type, matching a set of parameters, from the database
     
     - parameter parameters: dictionary containing the parameters identifying objects to be deleted
     - parameter type:       the type of the objects to be deleted
     
     - returns:              boolean indicating the success of the request
     */
    
    public func deleteObjectsWithParameters <T where T: NSObject, T: Storeable> (parameters: [String: AnyObject] = [:], forType type: T.Type) -> Bool {
        let tableName       = tableNameForType(T)
        let sql             = "DELETE FROM \(tableName)" + whereClauseForParameters(parameters)
        
        return self.exequteStatement(sql, parameters: parameters)
    }
    
    
    /**
     Get objects of a specified type, matching a set of parameters, from the database
     
     - parameter parameters: dictionary containing the parameters identifying objects to be retrieved
     - parameter type:       the type of the objects to be retrieved
     
     - returns:              array containing the retrieved objects
     */
    
    public func getObjectWithParameters <T where T: NSObject, T: Storeable> (parameters: [String: AnyObject]? = nil, forType type: T.Type) -> [T] {
        
        let tableName       = tableNameForType(T)
        let sql             = "SELECT * FROM \(tableName)" + whereClauseForParameters(parameters)
        
        
        var results: [T] = []
        
        databaseQueue.inDatabase { (database) -> Void in
            let resultSet = database.executeQuery(sql, withParameterDictionary: parameters)
            
            if resultSet != nil {
                while resultSet.next() {
                    
                    let object = type.init()
                    let mirror = Mirror(reflecting: object)
                    
                    var dictionary: [String: AnyObject] = [:]
                    for (key, child) in mirror.children {
                        if key == nil || type.ignoredProperties?().contains(key!) ?? false {
                            continue
                        }
                        
                        let childMirror = Mirror(reflecting: child)
                        
                        let childType: Any.Type = childMirror.subjectType
                        
                        switch childType {
                        case is String.Type, is (String?).Type, is Array<String>.Type, is (Array<String>?).Type:
                            dictionary[key!] = resultSet.stringForColumn(key!)
                        case is Bool.Type, is (Bool?).Type:
                            dictionary[key!] = resultSet.boolForColumn(key!)
                        case is NSNumber.Type, is (NSNumber?).Type:
                            dictionary[key!] = NSNumber(double: resultSet.doubleForColumn(key!))
                        case is NSData.Type, is (NSData?).Type:
                            dictionary[key!] = resultSet.dataForColumn(key!)
                        case is NSDate.Type, is (NSDate?).Type:
                            dictionary[key!] = resultSet.dateForColumn(key!)
                        default:
                            continue
                        }
                    }

                    let objectWithData = self.objectWithData(dictionary, forType: T.self)
                    results.append(objectWithData)
                }
                
                resultSet.close()
            }
        }
        
        return results
    }
    
    
    
    /**
     Removes null objects and joins arrays using ';' as separator
     
     - parameter data:   dictionary containing data from an object
     - parameter type:   type of object the data represents
     
     - returns:          a storeable dictionary
     */
    
    private func storeableDataFromObject <T where T: NSObject, T: Storeable> (object: T) -> [String: AnyObject] {
        var validData: [String: AnyObject] = [:]
        
        for (key, value) in dataFromObject(object) {
            if let arrayValue = value as? Array<String> {
                validData[key] = arrayValue.joinWithSeparator(";")
            } else {
                validData[key] = value
            }
        }
        
        return validData
    }

    
    
    private func tableNameForType(type: NSObject.Type) -> String {
        return NSStringFromClass(type).componentsSeparatedByString(".").last!
    }
    
    
    private func whereClauseForParameters(parameters: [String: AnyObject]?) -> String {
        if parameters == nil {
            return ""
        }
        
        let segments = parameters?.map { "\($0.0) = :\($0.0)" }
        
        return " WHERE " + segments!.joinWithSeparator(" AND ")
    }
    
    
    private func exequteStatement(statement: String, parameters: [String: AnyObject] = [:]) -> Bool {
        var isSuccess: Bool = false
        databaseQueue.inDatabase { (database) -> Void in
            isSuccess = database.executeUpdate(statement, withParameterDictionary: parameters)
        }
        
        return isSuccess
    }
    
    
    
    
    
    private func objectWithData <T where T: NSObject, T: Storeable> (data: [String: AnyObject], forType type: T.Type) -> T {
        let object = type.init()
        
        let mirror = Mirror(reflecting: object)
        for (key, child) in mirror.children {
            if key == nil || data[key!] == nil {
                continue
            }
            
            let childMirror = Mirror(reflecting: child)
            let childType: Any.Type = childMirror.subjectType
            
            if childType is Array<String>.Type || childType is (Array<String>?).Type {
                let array = (data[key!] as! String).componentsSeparatedByString(";")
                object.setValue(array, forKey: key!)
            } else {
                object.setValue(data[key!], forKey: key!)
            }
        }
        
        return object
    }
    
    /**
     Serialize the object
     
     - returns:              A dictionary containing the data from the object
     */
    
    private func dataFromObject <T where T: NSObject, T: Storeable> (object: T) -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        let mirror = Mirror(reflecting: object)
        
        for (key, child) in mirror.children {
            if key == nil || T.self.ignoredProperties?().contains(key!) ?? false {
                continue
            }

            dictionary[key!] = self.unwrap(child) as? AnyObject
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
}