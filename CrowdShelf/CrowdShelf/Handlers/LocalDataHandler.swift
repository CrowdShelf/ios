//
//  LocalDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


/**
Predefined file names:

- Book
- User
- Crowd
- Shelf
- BookDetail
*/

public struct LocalDataFile {
    static let Book = "book"
    static let User = "user"
    static let Crowd = "crowd"
    static let Shelf = "shelf"
    static let BookDetail = "bookDetails"
}


/**
A class reponsible for managing a local key-value storage.

:discussion: Files will be automatically created when needed. Initial values can be provided by a file in the main bundle with the same file name and type.
*/

public class LocalDataHandler {
    
    
//    MARK: - Setters
    
    
    /**
    Change the value for the provided key in a file
    
    - parameter 	object:      object that will be the new value
    - parameter     key:         key for which to change the value
    - parameter     fileName:    name of the file in which to change the value
    
    - returns: 	Boolean indicatig the success of the operation
    */
    
    public class func setObject(object : AnyObject?, forKey key: String, inFile fileName: String) -> Bool {
        var data = self.getDataFromFile(fileName)
        
        if object != nil {
            data[key] = object
        } else {
            data.removeValueForKey(key)
        }
        
        return self.setData(data, inFile: fileName)
    }
    
    
    /**
    Overwrites all data in a file
    
    - parameter 	fileName:    file that will be created or overwritten
    
    - returns: 	Boolean indicatig the success of the operation
    */
    
    public class func setData(data: [String: AnyObject]?, inFile fileName: String) -> Bool {
        let plistPath = self.pathToFileInDocumentsDirectory(fileName, ofType: "plist")
        
        if data == nil {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(plistPath)
                return true
            } catch _ {
                return false
            }
        }
        
        return (data! as NSDictionary).writeToFile(plistPath, atomically: true)
    }
    
    
//    MARK: - Getters
    
    /**
    Returns all data found in a file as a dictionary
    
    - parameter     fileName:    file to be read
    
    - returns: 	A dictionary containing the data from the file
    */
    
    public class func getDataFromFile(fileName: String) -> [String: AnyObject] {
        let plistPath = self.pathToFileInDocumentsDirectory(fileName, ofType: "plist")

        if NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
            return NSDictionary(contentsOfFile: plistPath) as! [String: AnyObject]
        } else {
            let bundleFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")
            if bundleFilePath != nil && NSFileManager.defaultManager().fileExistsAtPath(bundleFilePath!) {
                return NSDictionary(contentsOfFile: bundleFilePath!) as! [String: AnyObject]
            }
        }
        
        return [String: AnyObject]()
    }
    
    /**
    Get the value for the provided key in a file
    
    - parameter     key:         key for for the value that will be returned
    - parameter     fileName:    name of the file that will be read
    
    - returns: 	An optional object
    */
    
    public class func getObjectForKey(key: String, fromFile fileName: String) -> AnyObject? {
        return self.getDataFromFile(fileName)[key]
    }
    
    
//    MARK: - Helpers
    
    /// Returns the path to a specified file in the documents directory
    private class func pathToFileInDocumentsDirectory(fileName: String, ofType fileType: String) -> String {
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] 
        return "\(documentsPath)/\(fileName).\(fileType)"
    }
}