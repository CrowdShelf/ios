//
//  LocalDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

//TODO: Should this support any key type?

/// Predefined file names for regular use
struct LocalDataFile {
    static let Book = "book"
    static let User = "user"
    static let Crowd = "crowd"
    static let Shelf = "shelf"
    static let BookDetails = "bookDetails"
}

/// A class reponsible for managing a local key-value storage.
/// Files will be automatically created when needed.
/// Initial values can be provided by a file in the main bundle with the same file name and type.

class CSLocalDataHandler {
    
    
//    MARK: - Setters
    
    /// Change the value for the provided key in a specified file
    class func setObject(object : AnyObject?, forKey key: String, inFile fileName: String) -> Bool {
        var data = CSLocalDataHandler.getDataFromFile(fileName)
        
        if object != nil {
            data[key] = object
        } else {
            data.removeValueForKey(key)
        }
        
        return self.setData(data, inFile: fileName)
    }
    
    /// Overwrites all data in a specified file
    class func setData(data: [String: AnyObject]?, inFile fileName: String) -> Bool {
        let plistPath = self.pathToFileInDocumentsDirectory(fileName, ofType: "plist")
        
        if data == nil {
            return NSFileManager.defaultManager().removeItemAtPath(plistPath, error: nil)
        }
        
        return (data! as NSDictionary).writeToFile(plistPath, atomically: true)
    }
    
    
//    MARK: - Getters
    
    /// Get all data from a specified file. Will return an empty dictionary if file does not exist.
    class func getDataFromFile(fileName: String) -> [String: AnyObject] {
        let plistPath = self.pathToFileInDocumentsDirectory(fileName, ofType: "plist")

        if NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
            return NSDictionary(contentsOfFile: plistPath) as! [String: AnyObject]
        } else {
            // If the file does not exist in the documents folder, look for initial values in the main bundle
            var bundleFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")
            if bundleFilePath != nil && NSFileManager.defaultManager().fileExistsAtPath(bundleFilePath!) {
                return NSDictionary(contentsOfFile: bundleFilePath!) as! [String: AnyObject]
            }
        }
        
        return [String: AnyObject]()
    }
    
    /// Get the value for the provided key from a specified file
    class func getObjectForKey(key: String, fromFile fileName: String) -> AnyObject? {
        return CSLocalDataHandler.getDataFromFile(fileName)[key]
    }
    
    
    
//    MARK: - Local Storage
    
//    MARK: - Book Details
    
    class func detailsForBook(isbn: String) -> CSBookDetails? {
        let detailsDictionary = self.getObjectForKey(isbn, fromFile: LocalDataFile.BookDetails) as? [String: AnyObject]
        return detailsDictionary != nil ? CSBookDetails(json: JSON(detailsDictionary!)) : nil
    }
    
    class func setDetails(details: CSBookDetails, forBook isbn: String) -> Bool {
        return self.setObject(details.toDictionary(), forKey: isbn, inFile: LocalDataFile.BookDetails)
    }
    
    class func removeDetailsForBook(isbn: String) -> Bool {
        return self.setObject(nil, forKey: isbn, inFile: LocalDataFile.BookDetails)
    }
    
    
    
//    MARK: - Helpers
    
    /// Returns the path to a specified file in the documents directory
    private class func pathToFileInDocumentsDirectory(fileName: String, ofType fileType: String) -> String {
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
        return "\(documentsPath)/\(fileName).\(fileType)"
    }
}