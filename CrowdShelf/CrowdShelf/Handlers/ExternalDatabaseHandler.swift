//
//  ExternalDatabaseHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 03/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import Alamofire

public class ExternalDatabaseHandler {
    
    public class func resultsForQuery(query: String, withCompletionHandler completionHandler: (([BookInformation])->Void)) {
        if query.characters.count < 2 {
            return completionHandler([])
        }
        
        self.resultsFromGoogleForQuery(query) { (bookInformationArray) -> Void in
            
            for bookInformation in bookInformationArray {
                if let URL = NSURL(string: bookInformation.thumbnailURLString!) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        if let thumbnailData = NSData(contentsOfURL: URL) {
                            bookInformation.thumbnailData = thumbnailData
                            completionHandler(bookInformationArray)
                        }
                    })
                }
            }
            
            completionHandler(bookInformationArray)
        }
    }
    
    
    
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
        
        self.informationFromGoogleAboutBook(isbn) { (bookInformationArray: [BookInformation]) -> Void in
            for bookInformation in bookInformationArray {
                
                
                if let URL = NSURL(string: bookInformation.thumbnailURLString!) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        if let thumbnailData = NSData(contentsOfURL: URL) {
                            bookInformation.thumbnailData = thumbnailData
                            completionHandler(bookInformationArray)
                        }
                    })
                }
            }
            
            completionHandler(bookInformationArray)
        }
    }
    
    
    //    MARK: - Books
    
    /**
    
    Add book to database or update existing one
    
    - parameter 	book:                 book that will be added or updated
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    */
    
    public class func addBook(book: Book, withCompletionHandler completionHandler: ((Book?) -> Void)?) {
        var data = book.serialize()
        data.removeValueForKey("_id")
        
        self.sendRequestWithSubRoute("books", usingMethod: .POST, andParameters: data, parameterEncoding: .JSON) { (result, isSuccess) -> Void in

            var book: Book?
            if let resultDictionary = result as? [String: AnyObject] {
                book = Book(dictionary: resultDictionary)
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
        }
    }
    
    /**
     
     Get book from database
     
     - parameter 	bookID:              ID of the book
     - parameter     completionHandler:   closure which will be called with the result of the request
     
     */
    
    public class func getBook(bookID: String, withCompletionHandler completionHandler: ((Book?)->Void)) {
        self.sendRequestWithSubRoute("books/\(bookID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            
            var book: Book?
            if let value = result as? [String: AnyObject] {
                book = Book(dictionary: value)
            }
            
            completionHandler(book)
        }
    }
    
    
    /**
     Get books from database matching query. Retrieves all books if parameters is nil
     
     - parameter     parameters:         dictionary containing key-value parameters used for querying
     - parameter     completionHandler:  closure which will be called with the result of the request
     
     */
    
    public class func getBooksWithParameters(parameters: [String: AnyObject]?, useCache cache: Bool = true, andCompletionHandler completionHandler: (([Book])->Void)) {
        
        self.sendRequestWithSubRoute("books", usingMethod: .GET, andParameters: parameters, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            var books: [Book] = []
            if let resultDictionary = result as? [String: AnyObject] {
                if let valueArray = resultDictionary["books"] as? [[String: AnyObject]] {
                    books = valueArray.map {Book(dictionary: $0)}
                }
            }
            
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
        
        self.sendRequestWithSubRoute("login", usingMethod: .POST, andParameters: ["username": username, "password": password], parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            
            var user: User?
            
            if isSuccess {
                if let userValue = result as? [String: AnyObject] {
                    user = User(dictionary: userValue)
                }
            }
            
            completionHandler(user)
        }
    }
    
    public class func userForUserID(userID: String, withCompletionHandler completionHandler: ((User?)->Void
        )) {
            
            self.sendRequestWithSubRoute("users/\(userID)", usingMethod: .GET) { (result, isSuccess) -> Void in
                
                var user: User?
                
                if isSuccess {
                    if let userValue = result as? [String: AnyObject] {
                        user = User(dictionary: userValue)
                    }
                }
                
                completionHandler(user)
                
            }
    }
    
    public class func userForUsername(username: String, withCompletionHandler completionHandler: ((User?)->Void
        )) {
            
            self.sendRequestWithSubRoute("users", usingMethod: .GET, andParameters: ["username":username], parameterEncoding: .URL) { (result, isSuccess) -> Void in
                
                
                var user: User?
                if isSuccess && result != nil {
                    if let userDictionaries = result!["users"] as? [AnyObject] {
                        if let userValue = userDictionaries.first as? [String: AnyObject] {
                            user = User(dictionary: userValue)
                        }
                    }
                }
                
                completionHandler(user)
                
            }
    }
    
    /**
     Get all users from the database
     
     - parameter     completionHandler:   closure which will be called with the result of the request
     
     */
    
    public class func usersWithCompletionHandler(completionHandler: (([User])->Void)) {
        self.sendRequestWithSubRoute("users", usingMethod: .GET) { (result, isSuccess) -> Void in
            
            var users: [User] = []
            
            if isSuccess {
                if let resultDictionary = result as? [String: AnyObject] {
                    if let resultsArray = resultDictionary["users"] as? [[String: AnyObject]] {
                        users = resultsArray.map {User(dictionary: $0)}
                    }
                }
            }
            
            completionHandler(users)
        }
    }
    
    /**
     Get user with the provided ID if it exists
     
     - parameter 	userID:              ID of the user
     - parameter     completionHandler:   closure which will be called with the result of the request
     
     */
    
    public class func getUser(userID: String, withCompletionHandler completionHandler: ((User?)->Void)) {
        self.sendRequestWithSubRoute("users/\(userID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            
            var user: User?
            
            if isSuccess {
                if let resultDictionary = result as? [String: AnyObject] {
                    user = User(dictionary: resultDictionary)
                }
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
        
        var parameters = user.serialize()
        parameters.removeValueForKey("_id")
        
        self.sendRequestWithSubRoute("users", usingMethod: .POST, andParameters: parameters, parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            
            var user: User?
            
            if isSuccess {
                if let value = result as? [String: AnyObject] {
                    user = User(dictionary: value)
                }
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
    
    //    MARK: - Crowds
    
    public class func getCrowdsWithParameters(parameters: [String: AnyObject]?, andCompletionHandler completionHandler: (([Crowd]) -> Void)) {
        
        self.sendRequestWithSubRoute("crowds", usingMethod: .GET, andParameters: parameters, parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            var crowds: [Crowd] = []
            
            if isSuccess {
                if let resultDictionary = result as? [String: AnyObject] {
                    if let resultsArray = resultDictionary["crowds"] as? [[String: AnyObject]] {
                        crowds = resultsArray.map {Crowd(dictionary: $0)}
                    }
                }
            }
            
            completionHandler(crowds)
        }
    }
    
    public class func getCrowd(crowdID: String, withCompletionHandler completionHandler: ((Crowd?)->Void)) {
        self.sendRequestWithSubRoute("crowds/\(crowdID)", usingMethod: .GET) { (result, isSuccess) -> Void in
            var crowd: Crowd?
            if let crowdValue = result as? [String: AnyObject] {
                crowd = Crowd(dictionary: crowdValue)
            }
            completionHandler(crowd)
        }
    }
    
    public class func createCrowd(crowd: Crowd, withCompletionHandler completionHandler: ((Crowd?)-> Void)) {
        self.sendRequestWithSubRoute("crowds", usingMethod: .POST, andParameters: crowd.serialize(), parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            var crowd: Crowd?
            
            if isSuccess {
                if let crowdDictionary = result as? [String: AnyObject] {
                    crowd = Crowd(dictionary: crowdDictionary)
                }
            }
            
            completionHandler(crowd)
        }
    }
    
    public class func updateCrowd(crowd: Crowd, withCompletionHandler completionHandler: ((Bool)-> Void)?) {
        self.sendRequestWithSubRoute("crowds/\(crowd._id!)", usingMethod: .PUT, andParameters: crowd.serialize(), parameterEncoding: .JSON) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    public class func deleteCrowd(crowdID: String, withCompletionHandler completionHandler: ((Bool)-> Void)?) {
        self.sendRequestWithSubRoute("crowds/\(crowdID)", usingMethod: .DELETE) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    
    public class func addUser(userID: String, toCrowd crowdID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        self.sendRequestWithSubRoute("crowds/\(crowdID)/members/\(userID)", usingMethod: .PUT) { (result, isSuccess) -> Void in
            completionHandler?(isSuccess)
        }
    }
    
    public class func removeUser(userID: String, fromCrowd crowdID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        self.sendRequestWithSubRoute("crowds/\(crowdID)/members/\(userID)", usingMethod: .DELETE) { (result, isSuccess) -> Void in
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
    
    //    MARK: - Internal
    
    /**
    Sends a request to a sub path of the enviroments host root
    
    - parameter 	subRoute:            subpath for the request from the environments host root
    - parameter     method:              HTTP method that should be used
    - parameter     parameters:          a dictionary with key-value parameters
    - parameter     parameterEncoding:   the Alamofire.ParameterEncoding to be used (e.g. URL or JSON)
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    internal class func sendRequestWithSubRoute(subRoute: String,
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
    
    internal class func sendRequestWithRoute(route: String,
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
                        csprint(CS_DEBUG_NETWORK, result.debugDescription)
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