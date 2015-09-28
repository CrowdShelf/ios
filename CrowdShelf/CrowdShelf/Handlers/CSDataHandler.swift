//
//  CSDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

/**
Notifications posted for important events

- LocalUserUpdated: 
    A user was authenticated or signed out

*/
public struct CSNotification {
    static let LocalUserUpdated = "localUserUpdated"
}


///Responsible for brokering between the server and client
public class CSDataHandler {

//    MARK: - Book Information
    
    /**
    
    Retrieve information about a book
    
    Checks the local cache for the information. If not present, it will query an information provider for the information and cache it for later
    
    - parameter 	isbn:                 international standard book number of the book
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func informationAboutBook(isbn: String, withCompletionHandler completionHandler: (([CSBookInformation])->Void)) {
        if isbn.characters.count != 10 && isbn.characters.count != 13 {
            return completionHandler([])
        }
        
        
        let cachedData = Realm.read {
            $0.objectForPrimaryKey(CSBookInformation.self, key: isbn)
        }

        if let cachedInformation = cachedData as? CSBookInformation {
            completionHandler([cachedInformation])
            return
        }
        
        
        self.informationFromGoogleAboutBook(isbn) { (bookInformationArray: [CSBookInformation]) -> Void in
            for bookInformation in bookInformationArray {
                if let URL = NSURL(string: bookInformation.thumbnailURLString) {
                    if let thumbnailData = NSData(contentsOfURL: URL) {
                        
                        Realm.write { realm -> Void in
                            bookInformation.thumbnailData = thumbnailData
                        }
                        
                    }
                }
            }
            
            if !self.cacheObjects(bookInformationArray) {
                csprint(CS_DEBUG_REALM, "Failed to add book information for isbn: \(isbn)")
            }
            
            completionHandler(bookInformationArray)
        }
        
    }
    
    private class func cacheObjects(objects: [Object]) -> Bool {
        return Realm.write { (realm) -> Void in
             realm.add(objects, update: true)
        }
    }
    
    
//    MARK: - Books
    
    /**
    
    Add book to database or update existing one
    
    - parameter 	book:                 book that will be added or updated
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func addBook(book: CSBook, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        self.sendRequestWithSubRoute("/books", usingMethod: .POST, andParameters: book.serialize(), parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    /**
    
    Remove book from database
    
    - parameter 	bookID:               id of the book that will be removed
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func removeBook(bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        self.sendRequestWithSubRoute("/books/\(bookID)", usingMethod: .DELETE) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    /**
    
    Get book from database
    
    - parameter 	bookID:              ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getBook(bookID: String, withCompletionHandler completionHandler: ((CSBook?)->Void)) {
        self.sendRequestWithSubRoute("/books/\(bookID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                let book = CSBook(value: value)
                return completionHandler(book)
            }
            
            completionHandler(nil)
        }
    }
    
    
    /**
    Get books from database matching query. Retrieves all books if parameters is nil
    
    - parameter     parameters:         dictionary containing key-value parameters used for querying
    - parameter     completionHandler:  closure which will be called with the result of the request
    
    */
    
    public class func getBooksWithParameters(parameters: [String: AnyObject]?, andCompletionHandler completionHandler: (([CSBook])->Void)) {
        self.sendRequestWithSubRoute("/books", usingMethod: .GET, andParameters: parameters, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            if let resultDictionary = result as? [String: AnyObject] {
                if let value = resultDictionary["books"] as? [[String: AnyObject]] {
                    let books = value.map {CSBook(value: $0)}
                    return completionHandler(books)
                }
            }
            
            completionHandler([])
        }
    }
    
    //    MARK: - Users
    
    /**
    Get user with the provided username if it exists
    
    - parameter 	userID:              ID of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getUser(userID: String, withCompletionHandler completionHandler: ((CSUser?)->Void)) {
        self.sendRequestWithSubRoute("/users/\(userID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            if let resultDictionary = result as? [String: AnyObject] {
                return completionHandler(CSUser(value: resultDictionary))
            }
            
            completionHandler(nil)
        }
    }
    
    /**
    Create a user in the database
    
    - parameter 	user:               user object containing information needed to create a user
    - parameter     completionHandler:  closure which will be called with the result of the request
    
    */
    
    public class func createUser(user: CSUser, withCompletionHandler completionHandler: ((CSUser?)->Void )) {
        
//        TODO: Fix on server and remove
        var parameters = user.serialize()
        parameters.removeValueForKey("_id")
        
        self.sendRequestWithSubRoute("/users", usingMethod: .POST, andParameters: parameters, parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                completionHandler(CSUser(value: value))
            }
            
            completionHandler(nil)
        }
    }
    
        
    /**
    Add renter to owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     bookID:              the ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func addRenter(renter: String, toBook bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        
        self.sendRequestWithSubRoute("books/\(bookID)/renter/\(renter)", usingMethod: .PUT, andParameters: nil, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    /**
    Remove renter from owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     bookID:              the ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func removeRenter(renter: String, fromBook bookID: String, withOwner username: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        self.sendRequestWithSubRoute("/books/\(bookID)/renter/\(username)", usingMethod: .DELETE, andParameters: nil, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
//    MARK: - General
        
    /**
    
    Extracts information from the results based on predefined, provider based key-value coded mapping. NSNull values are discarded
    
    - parameter results:    the dictionary retrieved form google's books API
    
    returns:    A dictionary containing values and keys based on the defined mapping
    
    */
    
    public class func dictionaryFromDictionary(originalDictionary: NSDictionary, usingMapping mapping: [String: String]) -> [String: AnyObject]{
        
        var dictionary: [String: AnyObject] = [:]
        for (key, keyPath) in mapping {
            if let value = originalDictionary.valueForKeyPath(keyPath) {
                if !(value is NSNull) {
                    dictionary[key] = value
                }
            }
        }
        
        return dictionary
    }
    
//    MARK: - Private

    /**
    Sends a request to a sub path of the enviroments host root
    
    - parameter 	subRoute:            subpath for the request from the environments host root
    - parameter     method:              HTTP method that should be used
    - parameter     parameters:          a dictionary with key-value parameters
    - parameter     parameterEncoding:   the Alamofire.ParameterEncoding to be used (e.g. URL or JSON)
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    class func sendRequestWithSubRoute(subRoute: String,
                                       usingMethod method: Alamofire.Method,
                                       andParameters parameters: [String: AnyObject]?,
                                       parameterEncoding: ParameterEncoding,
                                       withCompletionHandler completionHandler: ((AnyObject?, Bool)->Void)?) {
                
        let route = CS_ENVIRONMENT.hostString() + subRoute
                           
        self.sendRequestWithRoute(route, usingMethod: method, andParameters: parameters, parameterEncoding: parameterEncoding, withCompletionHandler: completionHandler)
    }
    
    /**
    Sends a request to a sub path of the enviroments host root. A shorthand for use without parameters
    
    - parameter 	subRoute:            subpath for the request from the environments host root
    - parameter     method:              HTTP method that should be used
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    class func sendRequestWithSubRoute(subRoute: String,
        usingMethod method: Alamofire.Method,
        withCompletionHandler completionHandler: ((AnyObject?, Bool)->Void)?) {
            
            let route = CS_ENVIRONMENT.hostString() + subRoute
            
            self.sendRequestWithRoute(route, usingMethod: method, andParameters: nil, parameterEncoding: ParameterEncoding.URL, withCompletionHandler: completionHandler)
    }
    
    
    /**
    The endpoint in the client application responsible for sending an asynchronous request and handle the response
    
    - parameter 	route:              route for the request
    - parameter     method:             HTTP method that should be used
    - parameter     parameters:         a dictionary with key-value parameters
    - parameter     parameterEncoding:  the Alamofire.ParameterEncoding to be used (e.g. URL or JSON)
    - parameter     completionHandler:  closure which will be called with the result of the request
    
    */
    
    class func sendRequestWithRoute(route: String,
                                    usingMethod method: Alamofire.Method,
                                    andParameters parameters: [String: AnyObject]?,
                                    parameterEncoding: ParameterEncoding,
                                    withCompletionHandler completionHandler: ((AnyObject?, Bool)->Void)?) {
            
            csprint(CS_DEBUG_NETWORK, "Send request to URL:", route)
            
                                        
            var JSONResponseHandlerFailed = true
                                        
            Alamofire.request(method, route, parameters: parameters, encoding: parameterEncoding, headers: ["Content-Type": "application/json"])
                .responseJSON { (request, response, result) -> Void in
                    
                    JSONResponseHandlerFailed = result.isFailure
                    
                    if !JSONResponseHandlerFailed {
                        completionHandler?(result.value, result.isSuccess)
                    }
                    
            }.responseData { (request, response, result) -> Void in
                
                if result.isSuccess {
                    csprint(CS_DEBUG_NETWORK, "Request successful:", request!)
                } else {
                    csprint(CS_DEBUG_NETWORK, "Request failed:", request!, "\nStatus code:", response?.statusCode ?? "none", "\nError:", result.debugDescription)
                }
                
                if JSONResponseHandlerFailed {
                    completionHandler?(nil, result.isSuccess)
                }
                
            }
    }
}