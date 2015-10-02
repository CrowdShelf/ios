//
//  DataHandler+Convenience.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 02/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


extension DataHandler {
    
    /**
    Retrieves a list of all users that own a book matching the parameters
    
    - parameter parameters:         a dictionary with parameter used to filter the results
    - parameter completionHandler:  a closure to be called with the results of the request
    */
    
    public class func ownersOfBooksWithParameters(parameters: [String: AnyObject]?, withCompletionHandler completionHandler: (([User]) -> Void) ) {
        DataHandler.getBooksWithParameters(parameters) { (books) -> Void in
            if books.isEmpty {
                return completionHandler([])
            }
            
            let ownerIDs: Set<String> = Set(books.map {$0.owner})
            
            DataHandler.usersWithCompletionHandler { users -> Void in
                let owners = users.filter {ownerIDs.contains($0._id)}
                
                completionHandler(owners)
            }
        }
    }
    
    /**
    Adds a user as renter of a random book that is available for rent, matches the provided isbn, and is owned by the specified user
    
    - parameter renterID:           ID of the renter
    - parameter ISBN:               international standard book number of the book to be rented
    - parameter ownerID:            ID of the owner
    - parameter completionHandler:  a closure to be called with the results of the request
    */
    public class func addRenter(renterID: String, toTitle isbn: String, withOwner ownerID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        DataHandler.getBooksWithParameters(["isbn": isbn, "owner":ownerID, "availableForRent": true]) { (books) -> Void in
            
            if books.isEmpty {
                completionHandler?(false)
                return
            }
            
            let randomBook = books[ Int(arc4random()) % books.count ]
            DataHandler.addRenter(renterID, toBook: randomBook._id, withCompletionHandler: { (isSuccess) -> Void in
                completionHandler?(isSuccess)
            })
        }
    }
    
    public class func removeRenter(renterID: String, fromTitle isbn: String, withOwner ownerID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        DataHandler.getBooksWithParameters(["isbn": isbn, "owner":ownerID, "rentedTo": renterID]) { (books) -> Void in
            
            if books.isEmpty {
                completionHandler?(false)
                return
            }
            
            let randomBook = books[ Int(arc4random()) % books.count ]
            DataHandler.removeRenter(renterID, fromBook: randomBook._id, withCompletionHandler: { (isSuccess) -> Void in
                completionHandler?(isSuccess)
            })
        }
    }
    
}