//
//  LocalDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON


/**
Predefined file names:

- Book
- User
- Crowd
- Shelf
- BookDetail
*/

public struct CSLocalDataFile {
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

public class CSLocalDataHandler {
    
    
//    MARK: - Setters
    
    
    /**
    Change the value for the provided key in a file
    
    :param: 	object      object that will be the new value
    :param:     key         key for which to change the value
    :param:     fileName    name of the file in which to change the value
    
    :returns: 	Boolean indicatig the success of the operation
    */
    
    public class func setObject(object : AnyObject?, forKey key: String, inFile fileName: String) -> Bool {
        var data = CSLocalDataHandler.getDataFromFile(fileName)
        
        if object != nil {
            data[key] = object
        } else {
            data.removeValueForKey(key)
        }
        
        return self.setData(data, inFile: fileName)
    }
    
    
    /**
    Overwrites all data in a file
    
    :param: 	fileName    file that will be created or overwritten
    
    :returns: 	Boolean indicatig the success of the operation
    */
    
    public class func setData(data: [String: AnyObject]?, inFile fileName: String) -> Bool {
        let plistPath = self.pathToFileInDocumentsDirectory(fileName, ofType: "plist")
        
        if data == nil {
            return NSFileManager.defaultManager().removeItemAtPath(plistPath, error: nil)
        }
        
        return (data! as NSDictionary).writeToFile(plistPath, atomically: true)
    }
    
    
//    MARK: - Getters
    
    /**
    Returns all data found in a file as a dictionary
    
    :param:     fileName    file to be read
    
    :returns: 	A dictionary containing the data from the file
    */
    
    public class func getDataFromFile(fileName: String) -> [String: AnyObject] {
        let plistPath = self.pathToFileInDocumentsDirectory(fileName, ofType: "plist")

        if NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
            return NSDictionary(contentsOfFile: plistPath) as! [String: AnyObject]
        } else {
            var bundleFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")
            if bundleFilePath != nil && NSFileManager.defaultManager().fileExistsAtPath(bundleFilePath!) {
                return NSDictionary(contentsOfFile: bundleFilePath!) as! [String: AnyObject]
            }
        }
        
        return [String: AnyObject]()
    }
    
    /**
    Get the value for the provided key in a file
    
    :param:     key         key for for the value that will be returned
    :param:     fileName    name of the file that will be read
    
    :returns: 	An optional object
    */
    
    public class func getObjectForKey(key: String, fromFile fileName: String) -> AnyObject? {
        return CSLocalDataHandler.getDataFromFile(fileName)[key]
    }
    
    
    
//    MARK: - Local Storage
    
//    MARK: - Book Details
    
    /**
    Get the details for an ISBN from cache
    
    :param:     isbn        international standard book number for a book
    
    :returns: 	An optional CSBookDetails object
    */
    
    public class func detailsForBook(isbn: String) -> CSBookDetails? {
        let detailsDictionary = self.getObjectForKey(isbn, fromFile: CSLocalDataFile.BookDetail) as? [String: AnyObject]
        return detailsDictionary != nil ? CSBookDetails(json: JSON(detailsDictionary!)) : nil
    }
    
    
    /**
    Add the details for an ISBN to cache
    
    :param:     details     book details to be cached
    :param:     isbn        international standard book number for a book
    
    :returns: 	A boolean indicating the success of the operation
    */
    
    public class func setDetails(details: CSBookDetails, forBook isbn: String) -> Bool {
        return self.setObject(details.toDictionary(), forKey: isbn, inFile: CSLocalDataFile.BookDetail)
    }
    
    
    /**
    Remove the details for an ISBN from cache
    
    :param:     isbn        international standard book number for a book
    
    :returns: 	A boolean indicating the success of the operation
    */
    
    public class func removeDetailsForBook(isbn: String) -> Bool {
        return self.setObject(nil, forKey: isbn, inFile: CSLocalDataFile.BookDetail)
    }
    
    
    
//    MARK: - Helpers
    
    /// Returns the path to a specified file in the documents directory
    private class func pathToFileInDocumentsDirectory(fileName: String, ofType fileType: String) -> String {
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
        return "\(documentsPath)/\(fileName).\(fileType)"
    }
}