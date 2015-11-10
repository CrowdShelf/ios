//
//  DataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift

/**
Notifications posted for important events

- LocalUserUpdated: 
    A user was authenticated or signed out

*/
public struct Notification {
    static let LocalUserUpdated = "localUserUpdated"
}


///Responsible for brokering between the server and client
public class DataHandler {

//    MARK: - Book Information
    
    public class func resultsForQuery(query: String, withCompletionHandler completionHandler: (([BookInformation])->Void)) {
        ExternalDatabaseHandler.resultsForQuery(query) { (bookInformation) -> Void in
            completionHandler(bookInformation)
        }
    }
    
    
    
    /**
    
    Retrieve information about a book
    
    Checks the local cache for the information. If not present, it will query an information provider for the information and cache it for later
    
    - parameter 	isbn:                 international standard book number of the book
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func informationAboutBook(isbn: String, withCompletionHandler completionHandler: (([BookInformation])->Void)) {
        let cachedData = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(["isbn": isbn], forType: BookInformation.self)
        
        if !cachedData.isEmpty {
            return completionHandler(cachedData)
        }
        
        ExternalDatabaseHandler.informationAboutBook(isbn) { (bookInformation) -> Void in            
            completionHandler(bookInformation)
            if !bookInformation.isEmpty {
                LocalDatabaseHandler.sharedInstance.addObject(bookInformation.first!)
            }
        }
    }
    
    
//    MARK: - Books
    
    /**
    
    Add book to database or update existing one
    
    - parameter 	book:                 book that will be added or updated
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func addBook(book: Book, withCompletionHandler completionHandler: ((Book?) -> Void)?) {
        ExternalDatabaseHandler.addBook(book) { (book) -> Void in
            if book != nil {
                LocalDatabaseHandler.sharedInstance.addObject(book!)
            }
            
            completionHandler?(book)
        }
    }
    
    /**
    
    Remove book from database
    
    - parameter 	bookID:               id of the book that will be removed
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func removeBook(bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        ExternalDatabaseHandler.removeBook(bookID) { (isSuccess) -> Void in
            LocalDatabaseHandler.sharedInstance.deleteObjectsWithParameters(["_id":bookID], forType: Book.self)
            completionHandler?(isSuccess)
        }
    }
    
    /**
    
    Get book from database
    
    - parameter 	bookID:              ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getBook(bookID: String, withCompletionHandler completionHandler: ((Book?)->Void)) {
        
        let book = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(["_id": bookID], forType: Book.self).first
        if book != nil {
            completionHandler(book)
        }
        
        ExternalDatabaseHandler.getBook(bookID) { (book) -> Void in
            completionHandler(book)
        }
    }
    
    
    /**
    Get books from database matching query. Retrieves all books if parameters is nil
    
    - parameter     parameters:         dictionary containing key-value parameters used for querying
    - parameter     completionHandler:  closure which will be called with the result of the request
    
    */
    
    public class func getBooksWithParameters(parameters: [String: AnyObject]?, useCache cache: Bool = true, andCompletionHandler completionHandler: (([Book])->Void)) {
        
        let books = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(parameters, forType: Book.self)
        if !books.isEmpty {
            completionHandler(books)
        }
        
        ExternalDatabaseHandler.getBooksWithParameters(parameters, useCache: cache) { (books) -> Void in
            LocalDatabaseHandler.sharedInstance.addObjects(books)
            completionHandler(books)
        }
    }
    
    //    MARK: - Users
    
    /**
    Login as user with the provided username if it exists
    
    - parameter 	username:            screen name of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func loginWithUsername(username: String, andPassword password: String, withCompletionHandler completionHandler: ((User?)->Void)) {
        ExternalDatabaseHandler.loginWithUsername(username, andPassword: password) { (user) -> Void in
            
            if user != nil {
                LocalDatabaseHandler.sharedInstance.addObject(user!)
            }
            
            completionHandler(user)
        }
    }

    
    public class func userForUsername(username: String, withCompletionHandler completionHandler: ((User?)->Void
        )) {
            
            let user = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(["username": username], forType: User.self).first
            if user != nil {
                completionHandler(user)
            }
            
            ExternalDatabaseHandler.userForUsername(username) { (user) -> Void in
                if user != nil {
                    LocalDatabaseHandler.sharedInstance.addObject(user!)
                }
                completionHandler(user)
            }
    }
    
    /**
    Get all users from the database
    
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func usersWithCompletionHandler(completionHandler: (([User])->Void)) {
        let users = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(forType: User.self)
        completionHandler(users)
        
        ExternalDatabaseHandler.usersWithCompletionHandler { (users) -> Void in
            LocalDatabaseHandler.sharedInstance.addObjects(users)
            completionHandler(users)
        }
    }
    
    /**
    Get user with the provided ID if it exists
    
    - parameter 	userID:              ID of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getUser(userID: String, withCompletionHandler completionHandler: ((User?)->Void)) {
        
        let user = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(["_id": userID], forType: User.self).first
        if user != nil {
            completionHandler(user)
        }
        
        ExternalDatabaseHandler.userForUserID(userID) { (user) -> Void in
            if user != nil {
                LocalDatabaseHandler.sharedInstance.addObject(user!)
            }
            completionHandler(user)
        }
    }
    
    
    /**
    Create a user in the database
    
    - parameter 	user:               user object containing information needed to create a user
    - parameter     completionHandler:  closure which will be called with the result of the request
    
    */
    
    public class func createUser(user: User, withCompletionHandler completionHandler: ((User?)->Void )) {
        
        ExternalDatabaseHandler.createUser(user) { (user) -> Void in
            
            if user != nil {
                LocalDatabaseHandler.sharedInstance.addObject(user!)
            }
            completionHandler(user)
            
        }
    }
    
        
    /**
    Add renter to owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     bookID:              the ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func addRenter(renterID: String, toBook bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        
        ExternalDatabaseHandler.addRenter(renterID, toBook: bookID, withCompletionHandler: completionHandler)
    }
    
    /**
    Remove renter from owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     bookID:              the ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func removeRenter(renterID: String, fromBook bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        
        ExternalDatabaseHandler.removeRenter(renterID, fromBook: bookID, withCompletionHandler: completionHandler)
    }
    
//    MARK: - Crowds
    
    public class func getCrowdsWithParameters(parameters: [String: AnyObject]?, andCompletionHandler completionHandler: (([Crowd]) -> Void)) {
        
        let crowds = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(parameters, forType: Crowd.self)
        completionHandler(crowds)
        
        ExternalDatabaseHandler.getCrowdsWithParameters(parameters) { (crowds) -> Void in
            
            LocalDatabaseHandler.sharedInstance.addObjects(crowds)
            completionHandler(crowds)
        }
    }
    
    public class func getCrowd(crowdID: String, withCompletionHandler completionHandler: ((Crowd?)->Void)) {
        
        let crowd = LocalDatabaseHandler.sharedInstance.getObjectWithParameters(["_id": crowdID], forType: Crowd.self).first
        if crowd != nil {
            completionHandler(crowd)
        }
        
        ExternalDatabaseHandler.getCrowd(crowdID) { (crowd) -> Void in
            if crowd != nil {
                LocalDatabaseHandler.sharedInstance.addObject(crowd!)
            }
            completionHandler(crowd)
        }
    }
    
    public class func createCrowd(crowd: Crowd, withCompletionHandler completionHandler: ((Crowd?)-> Void)) {
        
        ExternalDatabaseHandler.createCrowd(crowd) { (crowd) -> Void in
            if crowd != nil {
                LocalDatabaseHandler.sharedInstance.addObject(crowd!)
            }
            completionHandler(crowd)
        }
        
    }
    
    public class func updateCrowd(crowd: Crowd, withCompletionHandler completionHandler: ((Bool)-> Void)?) {
        
        ExternalDatabaseHandler.updateCrowd(crowd) { (isSuccess) -> Void in
            if isSuccess {
                LocalDatabaseHandler.sharedInstance.addObject(crowd)
            }
            
            completionHandler?(isSuccess)
        }
        
    }
    
    public class func deleteCrowd(crowdID: String, withCompletionHandler completionHandler: ((Bool)-> Void)?) {
        ExternalDatabaseHandler.deleteCrowd(crowdID) { (isSuccess) -> Void in
            
            if isSuccess {
                LocalDatabaseHandler.sharedInstance.deleteObjectsWithParameters(["_id":crowdID], forType: Crowd.self)
            }
            completionHandler?(isSuccess)
        }
    }
    
    
    public class func addUser(userID: String, toCrowd crowdID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        ExternalDatabaseHandler.addUser(userID, toCrowd: crowdID, withCompletionHandler: completionHandler)
    }
    
    public class func removeUser(userID: String, fromCrowd crowdID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        ExternalDatabaseHandler.removeUser(userID, fromCrowd: crowdID, withCompletionHandler: completionHandler)
    }
}