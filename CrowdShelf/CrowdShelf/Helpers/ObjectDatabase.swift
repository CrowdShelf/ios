//
//  ObjectDatabase.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 03/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//


import Foundation
import UIKit


protocol Storeable {
    static var columnDefinitions: [String: [String]] {get}
    var asDictionary: [String: AnyObject] {get}
}

class ObjectDatabase {
    
    private let databaseQueue : FMDatabaseQueue

    
    init(databaseName: String) {
        let documentsDir : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let databasePath = documentsDir+"/\(databaseName).sqlite"
        
        /**/
        try! NSFileManager.defaultManager().removeItemAtPath(databasePath)
        /**/
        
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
     - parameter columnDefinitions: dictionary containing the column name and properties
     
     - returns:                     boolean indicating the success of the operation
     */
    
    func createTableForType <T where T: NSObject, T: Storeable> (type: T.Type) -> Bool {
        
        let columnStrings = T.columnDefinitions.map { (name, properties) -> String in
            return ([name] + properties).joinWithSeparator(" ")
            }
            .joinWithSeparator(", ")
        
        
        let tableName =  tableNameForType(T.self)
        let sql = "CREATE TABLE \(tableName) (\(columnStrings))"
        
        return self.exequteStatement(sql)
    }
    
    
    
    
    /**
     Add an object of a specified type, represented by a dictionary, to the database
     
     - parameter object:     a dictionary containing the data form the object to be added
     - parameter type:       the type of the object to be added
     
     - returns:              boolean indicating the success of the request
     */
    
    func addObject <T where T: NSObject, T: Storeable> (object: T, update: Bool = true) -> Bool {
        let validObject     = storeableDataFromData(object.asDictionary, forType: T.self)
        
        let valuesString    = validObject.keys.sort().map {":\($0)"}.joinWithSeparator(", ")
        let keysString      = validObject.keys.sort().map {"\($0)"}.joinWithSeparator(", ")
        let tableName       = tableNameForType(T.self)
        
        let method          = update ? "INSERT OR REPLACE" : "INSERT"
        let sql             = method + " INTO \(tableName) (\(keysString)) VALUES (\(valuesString))"
        
        return self.exequteStatement(sql, parameters: validObject)
    }
    
    
    /**
     Remove objects of a specified type, matching a set of parameters, from the database
     
     - parameter parameters: dictionary containing the parameters identifying objects to be deleted
     - parameter type:       the type of the objects to be deleted
     
     - returns:              boolean indicating the success of the request
     */
    
    func deleteObjectsWithParameters <T where T: NSObject, T: Storeable> (parameters: [String: AnyObject] = [:], forType type: T.Type) -> Bool {
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
    
    func getObjectWithParameters <T where T: NSObject, T: Storeable> (parameters: [String: AnyObject]? = nil, forType type: T.Type) -> [T] {
        
        let tableName       = tableNameForType(T)
        let sql             = "SELECT * FROM \(tableName)" + whereClauseForParameters(parameters)
        
        
        var results: [T] = []
        
        databaseQueue.inDatabase { (database) -> Void in
            let resultSet = database.executeQuery(sql, withParameterDictionary: parameters)
            
            while resultSet.next() {
                let object = type.init()
                
                //                var dictionary: [String: AnyObject] = [:]
                //
                //                let columnDefintitions = (type as! Storeable.Type).columnDefinitions
                //
                //                for (column, properties) in columnDefintitions {
                //                    if properties.contains("TEXT") {
                //                        dictionary[column] = resultSet.stringForColumn(column)
                //                    } else if properties.contains("INT") {
                //                        dictionary[column] = Int(resultSet.intForColumn(column))
                //                    } else if properties.contains("REAL") {
                //                        dictionary[column] = Double(resultSet.doubleForColumn(column))
                //                    } else if properties.contains("BOOL") {
                //                        dictionary[column] = resultSet.boolForColumn(column)
                //                    } else if properties.contains("BLOB") {
                //                        dictionary[column] = resultSet.dataForColumn(column)
                //                    } else if properties.contains("DATE") {
                //                        dictionary[column] = resultSet.dateForColumn(column)
                //                    }
                //                }
                //
                let validValues = self.validDataFromData(resultSet.resultDictionary() as! [String: AnyObject], forType: T.self)
                for (key, value) in validValues {
                    object.setValue(value, forKey: key )
                }
                
                results.append(object)
            }
            
            resultSet.close()
        }
        
        return results
    }
    
    
    
    /**
     Removes null objects and joins arrays using ';' as separator
     
     - parameter data:   dictionary containing data from an object
     - parameter type:   type of object the data represents
     
     - returns:          a storeable dictionary
     */
    
    private func storeableDataFromData(data: [String: AnyObject], forType type: NSObject.Type) -> [String: AnyObject] {
        var validData: [String: AnyObject] = [:]
        
        
        for (key, value) in data {
            var validValue: AnyObject? = value
            
            if let arrayValue = value as? Array<String> {
                validValue = arrayValue.joinWithSeparator(";")
            }
            
            if validValue != nil {
                validData[key] = validValue
            }
        }
        
        return validData
    }
    
    
    /**
     Removes NSNull objects and splits strings representing arrays
     
     - parameter data:   dictionary containing data a table
     - parameter type:   type of object the table represents
     
     - returns:          a dictionary representing an object of the specified type
     */
    
    private func validDataFromData(data: [String: AnyObject], forType type: NSObject.Type) -> [String: AnyObject] {
        
        var validData: [String: AnyObject] = [:]
        
        for (key, value) in data {
            if value is NSNull {
                continue
            }
            
            var validValue: AnyObject   = value
            
            
            // FIXME: Horrible way to get the property type
            let property                = class_getProperty(type, key)
            let propertyName            = String(CString: property_getAttributes(property), encoding: NSUTF8StringEncoding)
            let propertyTypeComponents  = propertyName!.componentsSeparatedByString("\"")
            
            if propertyTypeComponents.count > 1 {
                let propertyType: AnyClass? = NSClassFromString(propertyTypeComponents[1])
                if propertyType is NSArray.Type {
                    validValue = (value as! String).componentsSeparatedByString(";")
                }
            }
            ///////
            
            validData[key] = validValue
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
}