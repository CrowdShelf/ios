//
//  DataHandler.swift
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
public struct Notification {
    static let LocalUserUpdated = "localUserUpdated"
}


///Responsible for brokering between the server and client
public class DataHandler {

//    MARK: - Book Information
    
    /**
    
    Retrieve information about a book
    
    Checks the local cache for the information. If not present, it will query an information provider for the information and cache it for later
    
    - parameter 	isbn:                 international standard book number of the book
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func informationAboutBook(isbn: String, withCompletionHandler completionHandler: (([BookInformation])->Void)) {
        if isbn.characters.count != 10 && isbn.characters.count != 13 {
            return completionHandler([])
        }
        
        
        let cachedData = Realm.read {
            $0.objectForPrimaryKey(BookInformation.self, key: isbn)
        }

        if let cachedInformation = cachedData as? BookInformation {
            completionHandler([cachedInformation])
            return
        }
        
        
        self.informationFromGoogleAboutBook(isbn) { (bookInformationArray: [BookInformation]) -> Void in
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
    
    public class func addBook(book: Book, withCompletionHandler completionHandler: ((Book?) -> Void)?) {
        self.sendRequestWithSubRoute("books", usingMethod: .POST, andParameters: book.serialize(), parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            if result == nil {
                completionHandler?(nil)
                return
            }
            
            let book = Book(value: result as! [String: AnyObject])
            
            Realm.write {
                $0.add(book, update: true)
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
        self.sendRequestWithSubRoute("books/\(bookID)", usingMethod: .DELETE) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
            
            if isSuccess {
                Realm.write {
                    let book = $0.objectForPrimaryKey(Book.self, key: bookID)
                    $0.delete(book!)
                }
            }
        }
    }
    
    /**
    
    Get book from database
    
    - parameter 	bookID:              ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getBook(bookID: String, withCompletionHandler completionHandler: ((Book?)->Void)) {
        self.sendRequestWithSubRoute("books/\(bookID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                let book = Book(value: value)
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
    
    public class func getBooksWithParameters(parameters: [String: AnyObject]?, useCache cache: Bool = true, andCompletionHandler completionHandler: (([Book])->Void)) {
        
        self.sendRequestWithSubRoute("books", usingMethod: .GET, andParameters: parameters, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            if let resultDictionary = result as? [String: AnyObject] {
                if let value = resultDictionary["books"] as? [[String: AnyObject]] {
                    let books = value.map {Book(value: $0)}
                    
                    Realm.write {
                        $0.add(books, update: true)
                    }
                    
                    return completionHandler(books)
                }
            }
            
            completionHandler([])
        }
    }
    
    //    MARK: - Users
    
    /**
    Login as user with the provided username if it exists
    
    - parameter 	username:            screen name of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func loginWithUsername(username: String, withCompletionHandler completionHandler: ((User?)->Void)) {
        self.usersWithCompletionHandler { (users) -> Void in
            for user in users {
                if user.username == username {
                    return completionHandler(user)
                }
            }
            
            completionHandler(nil)
        }
    }
    
    /**
    Get all users from the database
    
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func usersWithCompletionHandler(completionHandler: (([User])->Void)) {
        self.sendRequestWithSubRoute("users", usingMethod: .GET) { (result, isSuccess) -> Void in
            if isSuccess {
                if let resultDictionary = result as? [String: AnyObject] {
                    if let usersArray = resultDictionary["users"] as? [[String: AnyObject]] {
                        return completionHandler(usersArray.map {User(value: $0)})
                    }
                }
            }
            
            completionHandler([])
        }
    }
    
    /**
    Get user with the provided ID if it exists
    
    - parameter 	userID:              ID of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getUser(userID: String, withCompletionHandler completionHandler: ((User?)->Void)) {
        self.sendRequestWithSubRoute("users/\(userID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            if let resultDictionary = result as? [String: AnyObject] {
                return completionHandler(User(value: resultDictionary))
            }
            
            completionHandler(nil)
        }
    }
    
    /**
    Create a user in the database
    
    - parameter 	user:               user object containing information needed to create a user
    - parameter     completionHandler:  closure which will be called with the result of the request
    
    */
    
    public class func createUser(user: User, withCompletionHandler completionHandler: ((User?)->Void )) {
        
//        TODO: Fix on server and remove
        var parameters = user.serialize()
        parameters.removeValueForKey("_id")
        
        self.sendRequestWithSubRoute("users", usingMethod: .POST, andParameters: parameters, parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                completionHandler(User(value: value))
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
    
    public class func addRenter(renterID: String, toBook bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        
        self.sendRequestWithSubRoute("books/\(bookID)/renter/\(renterID)", usingMethod: .PUT, andParameters: nil, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    /**
    Remove renter from owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     bookID:              the ID of the book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func removeRenter(renterID: String, fromBook bookID: String, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        self.sendRequestWithSubRoute("books/\(bookID)/renter/\(renterID)", usingMethod: .DELETE, andParameters: nil, parameterEncoding: .URL) { (result, isSuccess) -> Void in
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
                                       andParameters parameters: [String: AnyObject]? = nil,
                                       parameterEncoding: ParameterEncoding = .URL,
                                       withCompletionHandler completionHandler: ((AnyObject?, Bool)->Void)?) {
                
        let route = CS_ENVIRONMENT.hostString() + subRoute
                           
        self.sendRequestWithRoute(route, usingMethod: method, andParameters: parameters, parameterEncoding: parameterEncoding, withCompletionHandler: completionHandler)
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
                    
                    JSONResponseHandlerFailed = result.isFailure || response!.statusCode != 200

                    if !JSONResponseHandlerFailed {
                        completionHandler?(result.value, result.isSuccess)
                    } else {
                        csprint(CS_DEBUG_NETWORK, "Response JSON failed for request:", request!, "\nStatus code:", response?.statusCode ?? "none", "\nError:", result.debugDescription)
                    }
                    
            }.responseData { (request, response, result) -> Void in
                
                if result.isSuccess {
                    csprint(CS_DEBUG_NETWORK, "Request successful:", request!, "\nStatus code:", response?.statusCode ?? "none")
                } else {
                    csprint(CS_DEBUG_NETWORK, "Request failed:", request!, "\nStatus code:", response?.statusCode ?? "none", "\nError:", result.debugDescription)
                }
                
                if JSONResponseHandlerFailed {
                    completionHandler?(nil, result.isSuccess && response!.statusCode == 200)
                }
                
            }
    }
}