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
    
    public class func informationAboutBook(isbn: String, withCompletionHandler completionHandler: ((CSBookInformation?)->Void)) {
        
        do {
            if let bookInformation = try Realm().objectForPrimaryKey(CSBookInformation.self, key: isbn) {
                return completionHandler(bookInformation)
            }
        } catch let error as NSError {
            csprint(CS_DEBUG_REALM, "Failed to retrieve book information from Realm for isbn: \(isbn)", "\nError:", error.debugDescription)
        }
        
        self.informationFromGoogleAboutBook(isbn) { (value: [String:AnyObject]?) -> Void in
            if value == nil {
                return completionHandler(nil)
            }
            
            var valueDictionary = value!
            self.makeJSONDictionaryRealmCompatible(&valueDictionary)
            
            let bookInformation = CSBookInformation(value: valueDictionary)
            
            if let imageData = NSData(contentsOfURL: NSURL(string: bookInformation.thumbnailURLString)!) {
                bookInformation.thumbnailData = imageData
            }
            
            completionHandler(bookInformation)
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(bookInformation, update: true)
                }
            }
            catch let error as NSError {
                csprint(CS_DEBUG_REALM, "Failed to add book information for isbn: \(isbn)", "\nError:", error.debugDescription)
            }
        }
    }
    
    
//    MARK: - Books
    
    /**
    
    Add book to database or update existing one
    
    - parameter 	book:                 book that will be added or updated
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func addBook(book: CSBook, withCompletionHandler completionHandler: ((Bool) -> Void)?) {
        self.sendRequestWithSubRoute("/books", usingMethod: .POST, andParameters: book.serialize() as? [String: AnyObject], parameterEncoding: .JSON) { (result, isSuccess) -> Void in
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
        self.sendRequestWithSubRoute("/crowds", usingMethod: .PUT, andParameters: crowd.serialize() as? [String : AnyObject], parameterEncoding: .JSON)  { (result, isSuccess) -> Void in
            if let value = result as? [String: AnyObject] {
                
                //
                var updatedValue = value
                self.makeJSONDictionaryRealmCompatible(&updatedValue)
                //
                
                completionHandler?(CSCrowd(value: updatedValue))
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
                
                //
                var updatedValue = value
                self.makeJSONDictionaryRealmCompatible(&updatedValue)
                //
                
                completionHandler(CSCrowd(value: updatedValue))
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
                    
                    //
                    var updatedValue = value
                    self.makeJSONDictionaryRealmCompatible(&updatedValue)
                    //
                    
                    return CSCrowd(value: updatedValue)
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
    
//    MARK: - Users
    
    /**
    Get user with the provided username if it exists
    
    - parameter 	username:            username of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    public class func getUser(username: String, withCompletionHandler completionHandler: ((CSUser?)->Void)) {
        self.sendRequestWithSubRoute("/users/\(username)", usingMethod: .GET) { (result, isSuccess) -> Void in
            if let resultDictionary = result as? [String: AnyObject] {
                return completionHandler(CSUser(value: resultDictionary))
            }
            
            completionHandler(nil)
        }
    }
    
    /// *Not yet implemented*
    public class func createUser(username: String, withCompletionHandler completionHandler: ((CSUser?)->Void )) {
        fatalError("Create user not implemented")
    }
    
    
//    MARK: - General
    
    //    TODO: Remove or improve this :)
    
    /**
    
    Should not be necessary? To be removed, or improved
    
    Prepares objects incompatible with realm to be wrapped by creating a dictionary with a key 'content' needed by the RLEWrapper initializer

    - parameter dictionary: A dictionary to be made compatible in a realm objects initializer

    */
    
    private class func makeJSONDictionaryRealmCompatible(inout dictionary: [String: AnyObject]) {
        for key in dictionary.keys {
            if let arrayValue = dictionary[key] as? [AnyObject] {
                if let _ = arrayValue as? [[String: AnyObject]] {
                    continue
                }
                
                dictionary[key] = arrayValue.map { ["content": $0] }
            }
        }
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