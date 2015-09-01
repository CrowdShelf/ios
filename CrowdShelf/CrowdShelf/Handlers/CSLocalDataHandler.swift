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
    
    /// Add book to shelf. Increment number of copies if the book is already added
    class func addBookToShelf(book: CSBook) -> Bool {
        var shelf = self.getObjectForKey(CSUser.localUser!.id!, fromFile: LocalDataFile.Shelf) as? [String: AnyObject]
        
        if shelf == nil {
            shelf = [book.isbn: book.toDictionary()]
        } else if shelf?[book.isbn] == nil {
            shelf?[book.isbn] = book.toDictionary()
        } else {
            let existingBook = CSBook(json: JSON(shelf![book.isbn]!))
            existingBook.numberOfCopies += book.numberOfCopies
            shelf?[existingBook.isbn] = existingBook.toDictionary()
        }
        
        return self.setObject(shelf, forKey: CSUser.localUser!.id!, inFile: LocalDataFile.Shelf)
    }
    
    class func removeBookFromShelf(book: CSBook) -> Bool {
        var shelf = self.getObjectForKey(CSUser.localUser!.id!, fromFile: LocalDataFile.Shelf) as? [String: AnyObject]
        
        if shelf == nil || shelf![book.isbn] == nil {
            return false
        }
        
        if let existingBookDictionary = shelf![book.isbn] as? [String: AnyObject] {
            let existingBook = CSBook(json: JSON(existingBookDictionary))
            existingBook.numberOfCopies--
            
            if existingBook.numberOfCopies <= 0 {
                
            } else {
                shelf?[existingBook.isbn] = existingBook.toDictionary()
            }
        }
        
        return self.setObject(shelf, forKey: CSUser.localUser!.id!, inFile: LocalDataFile.Shelf)
    }
    
    class func shelf() -> [CSBook] {
        let userShelf = self.getObjectForKey(CSUser.localUser!.id!, fromFile: LocalDataFile.Shelf) as? [String: AnyObject]
        if userShelf == nil {
            return []
        }
        
        return map(userShelf!.values) {
            CSBook(json: JSON($0 as! [String: AnyObject]))
        }
    }
    
    
//    MARK: - Crowds
    
    class func crowds() -> [CSCrowd] {
        let userCrowds = self.getObjectForKey(CSUser.localUser!.id!, fromFile: LocalDataFile.Crowd) as? [String: AnyObject]
        if userCrowds == nil {
            return []
        }
        
        return map(userCrowds!.values) {
            CSCrowd(json: JSON($0 as! [String: AnyObject]))
        }
    }
    
    class func setCrowd(crowd: CSCrowd) -> Bool {
        var userCrowds = self.getObjectForKey(CSUser.localUser!.id!, fromFile: LocalDataFile.Crowd) as? [String: AnyObject]
        if userCrowds == nil {
            return false
        }
        
        userCrowds![crowd.id] = crowd.toDictionary()
        
        return self.setObject(userCrowds, forKey: CSUser.localUser!.id!, inFile: LocalDataFile.Crowd)
    }
    
    class func removeCrowd(crowd: CSCrowd) -> Bool {
        var userCrowds = self.getObjectForKey(CSUser.localUser!.id!, fromFile: LocalDataFile.Crowd) as? [String: AnyObject]
        if userCrowds == nil {
            return false
        }
        
        userCrowds!.removeValueForKey(crowd.id)
        
        return self.setObject(userCrowds, forKey: CSUser.localUser!.id!, inFile: LocalDataFile.Crowd)
    }
    
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