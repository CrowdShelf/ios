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
        if isbn.characters.count < 10 {
            return completionHandler([])
        }
        
        do {
            if let bookInformation = try Realm().objectForPrimaryKey(CSBookInformation.self, key: isbn) {
                return completionHandler([bookInformation])
            }
        } catch let error as NSError {
            csprint(CS_DEBUG_REALM, "Failed to retrieve book information from Realm for isbn: \(isbn)", "\nError:", error.debugDescription)
        }
        
        self.informationFromGoogleAboutBook(isbn) { (bookInformationArray: [CSBookInformation]) -> Void in
            for bookInformation in bookInformationArray {
                if let URL = NSURL(string: bookInformation.thumbnailURLString) {
                    if let thumbnailData = NSData(contentsOfURL: URL) {
                        do {
                            let realm = try Realm()
                            try realm.write {
                                bookInformation.thumbnailData = thumbnailData
                            }
                        } catch {
                            
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
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(objects, update: true)
            }
            return true
        }
        catch let error as NSError {
            csprint(CS_DEBUG_REALM, error.description)
            return false
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
                let book = CSBook(value: self.realmCompatibleDictionaryFromDictionary(value))
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
                    let books = value.map {CSBook(value: self.realmCompatibleDictionaryFromDictionary($0))}
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
                return completionHandler(CSUser(value: self.realmCompatibleDictionaryFromDictionary(resultDictionary)))
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
    
    
//    MARK: - NOT YET IMPLEMENTED -
    
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
    
//    MARK: - Crowds
    
    /**
    Create a new crowd in the database. If successful, a crowd object with correct id is returned
    
    - parameter 	crowd:               a crowd object representing the new crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func createCrowd(crowd: CSCrowd, withCompletionHandler completionHandler: ((CSCrowd?)->Void)?) {
        self.sendRequestWithSubRoute("/crowds", usingMethod: .POST, andParameters: crowd.serialize() as? [String : AnyObject], parameterEncoding: .JSON)  { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                completionHandler?(CSCrowd(value: self.realmCompatibleDictionaryFromDictionary(value)))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    /**
    Get crowd for id from database
    
    - parameter 	crowdID:             id of the crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func getCrowd(crowdID: String, withCompletionHandler completionHandler: ((CSCrowd?)->Void)) {
        
        self.sendRequestWithSubRoute("/crowds/\(crowdID)", usingMethod: .GET, andParameters: nil, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                completionHandler(CSCrowd(value: self.realmCompatibleDictionaryFromDictionary(value)))
            } else {
                completionHandler(nil)
            }
        }
    }
    
    /**
    Get crowds form database
    
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func getCrowdsWithCompletionHandler(completionHandler: (([CSCrowd]) -> Void) ) {
        self.sendRequestWithSubRoute("/crowds", usingMethod: .GET, andParameters: nil, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            if let values = result as? [[String: AnyObject]] {
                completionHandler(values.map { (value) -> CSCrowd in
                    return CSCrowd(value: self.realmCompatibleDictionaryFromDictionary(value))
                })
            } else {
                completionHandler([])
            }
        }
    }
    
    /**
    Add member to crowd
    
    - parameter 	username:            username of the member
    - parameter     crowdID:             id of the crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func addMember(username: String, toCrowd crowdID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        self.sendRequestWithSubRoute("/crowds/\(crowdID)/members/\(username)", usingMethod: .PUT) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    /**
    Remove member from crowd
    
    - parameter 	username:            username of the member
    - parameter     crowdID:             id of the crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func removeMember(username: String, fromCrowd crowdID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        
        self.sendRequestWithSubRoute("/crowds/\(crowdID)/members/\(username)", usingMethod: .DELETE) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    
//    MARK: - General
    
    //    TODO: Remove or improve this :)
    
    /**
    
    Should not be necessary? To be removed, or improved
    
    Prepares objects incompatible with realm to be wrapped by creating a dictionary with a key 'content' needed by the RLEWrapper initializer

    - parameter dictionary: A dictionary to be made compatible in a realm objects initializer

    */
    
    class func realmCompatibleDictionaryFromDictionary(dictionary: [String: AnyObject]) -> [String: AnyObject] {
        var realCompatibleDictionary = [String:AnyObject]()
        
        for key in dictionary.keys {
            if dictionary[key] is NSNull {
                realCompatibleDictionary.removeValueForKey(key)
            } else if let arrayValue = dictionary[key] as? [AnyObject] {
                if let _ = arrayValue as? [[String: AnyObject]] {
                    continue
                }
                
                realCompatibleDictionary[key] = arrayValue.map { ["content": $0] }
            } else {
                realCompatibleDictionary[key] = dictionary[key]
            }
        }
        
        return realCompatibleDictionary
    }
    
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
    The endpoint in the client application responsible for sending an asynchronous request and converting the response to a JSON object
    
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
            
            Alamofire.request(method, route, parameters: parameters, encoding: parameterEncoding, headers: ["Content-Type": "application/json"])
                .responseJSON { (request, response, result) -> Void in
                    
                    if result.isFailure {
                        csprint(CS_DEBUG_NETWORK, "Request failed:", request!, "\nStatus code:", response?.statusCode ?? "none", "\nError:", result.debugDescription)
                    } else {
                        csprint(CS_DEBUG_NETWORK, "Request successful:", request!)
                    }
                    
                    completionHandler?(result.value, result.isSuccess)
            }
    }
}