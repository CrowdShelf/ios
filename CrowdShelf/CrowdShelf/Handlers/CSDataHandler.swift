//
//  CSDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON


/**
The supported HTTP methods:

- GET
- PUT
- POST
- DELETE

*/
public enum CSHTTPMethod : String {
    case GET    = "GET"
    case POST   = "POST"
    case PUT    = "PUT"
    case DELETE = "DELETE"
}


/**
Notifications posted for important events

- LocalUserUpdated: 
    A user was authenticated or signed out

*/
public struct CSNotification {
    static let LocalUserUpdated = "localUserUpdated"
}


/// A closure type with a boolean parameter indicating the success of a request
public typealias CSBooleanCompletionHandler = ((Bool)->Void)?

/// A closure type with an optional JSON parameter which represents any received data
public typealias CSCompletionHandler = ((JSON?)->Void)



///Responsible for brokering between the server and client
public class CSDataHandler {
    
    /// The root url for the database
    class var host : String {
        return "https://crowdshelf.herokuapp.com/api"
    }

//    MARK: Books
    
    public class func informationForBook(isbn: String, withCompletionHandler completionHandler: ((CSBookInformation?)->Void)) {

        if let bookInformation = CSLocalDataHandler.detailsForBook(isbn) {
            return completionHandler(bookInformation)
        }
        
        CSGoogleBooksHandler.informationForBook(isbn, withCompletionHandler: { (bookInformation) -> Void in
            if bookInformation != nil {
                CSLocalDataHandler.setDetails(bookInformation!, forBook: isbn)
            }
            
            completionHandler(bookInformation)
        })
    }
    
    /**
    
    Add book to database or update existing one
    PUT /book
    
    - parameter 	book:                 book that will be added or updated
    - parameter     completionHandler:    closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func addBook(book: CSBook, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        self.sendRequestWithRoute("/book", andData: book.toJSON(), usingMethod: .PUT, withCompletionHandler: completionHandler)
    }
    
    /**
    Get book from database
    
    - parameter 	isbn:                international standard book number for the book that will be added or updated
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func getBook(isbn: String, owner: String, withCompletionHandler completionHandler: ((CSBook?)->Void)) {
        self.sendRequestWithRoute("/book/\(isbn)/\(owner)", usingMethod: .GET) { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSBook(json: json!))
        }
    }
    
    /**
    Add renter to owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     isbn:                international standard book number for the book
    - parameter     owner:               username of the owner
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func addRenter(renter: String, toBook isbn: String, withOwner owner: String, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        self.sendRequestWithRoute("/book/\(isbn)/\(owner)/addrenter", andData: JSON(["username": renter]), usingMethod: .PUT, withCompletionHandler: completionHandler)
    }
    
    /**
    Remove renter from owners book in database
    
    - parameter 	renter:              username of the renter
    - parameter     isbn:                international standard book number for the book
    - parameter     owner:               username of the owner
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func removeRenter(renter: String, fromBook isbn: String, withOwner owner: String, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        self.sendRequestWithRoute("/book/\(isbn)/\(owner)/removerenter", andData: JSON(["username": renter]), usingMethod: .PUT, withCompletionHandler: completionHandler)
    }
    
//    MARK: - Crowds
    
    /**
    Create a new crowd in the database. If successful, a crowd object with correct id is returned
    
    - parameter 	crowd:               a crowd object representing the new crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func createCrowd(crowd: CSCrowd, withCompletionHandler completionHandler: ((CSCrowd?)->Void)?) {
        self.sendRequestWithRoute("/crowd", andData: crowd.toJSON(), usingMethod: .PUT) { (json) -> Void in
            if json == nil {
                completionHandler?(nil)
            } else {
                completionHandler?(CSCrowd(json: json!))
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
        self.sendRequestWithRoute("/crowd/\(crowdID)", usingMethod: .GET) { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSCrowd(json: json!))
        }
    }
    
    /**
    Get crowds form database
    
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func getCrowdsWithCompletionHandler(completionHandler: (([CSCrowd]) -> Void) ) {
        self.sendRequestWithRoute("/crowd", usingMethod: .GET) { (json) -> Void in
            if json == nil {
                completionHandler([])
            }

            completionHandler(json!["crowds"].arrayValue.map({
                CSCrowd(json: $0)
            }))
        }
    }
    
    /**
    Add member to crowd
    
    - parameter 	username:            username of the member
    - parameter     crowdID:             id of the crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func addMember(username: String, toCrowd crowdID: String, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        
        self.sendRequestWithRoute("/crowd/\(crowdID)/addmember", andData: JSON(["username": username]), usingMethod: .PUT, withCompletionHandler: completionHandler)
    }
    
    /**
    Remove member from crowd
    
    - parameter 	username:            username of the member
    - parameter     crowdID:             id of the crowd
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func removeMember(username: String, fromCrowd crowdID: String, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        
        self.sendRequestWithRoute("/crowd/\(crowdID)/removemember", andData: JSON(["username": username]), usingMethod: .PUT, withCompletionHandler: completionHandler)
    }
    
//    MARK: - Users
    
    /**
    Get user with the provided username if it exists
    
    - parameter 	username:            username of the user
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func getUser(username: String, withCompletionHandler completionHandler: ((CSUser?)->Void)) {
        self.sendRequestWithRoute("/user/\(username)", usingMethod: .GET) { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSUser(json: json!))
        }
    }
    
    /// *Not yet implemented*
    public class func createUser(username: String, withCompletionHandler completionHandler: ((CSUser?)->Void )) {
        fatalError("Create user not implemented")
    }
    
    
//    MARK: - Private
    
    /**
    A convenience method for requests without body data that does not provide a data object, but a boolean indicating the success of the request
    
    - parameter 	subRoute:            subpath for the request from the host root
    - parameter     method:              HTTP method that should be used
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    private class func sendRequestWithRoute(subRoute: String, usingMethod method: CSHTTPMethod, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        self.sendRequestWithRoute(subRoute, andData: nil, usingMethod: method) { (json) in
            if json == nil {
                completionHandler?(false)
                return
            }
            
            completionHandler?(true)
        }
    }
    
    /**
    A convenience method for requests that does not provide a data object, but a boolean indicating the success of the request
    
    - parameter 	subRoute:            subpath for the request from the host root
    - parameter     json:                an optional JSON object. This will become the body of the request
    - parameter     method:              HTTP method that should be used
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    private class func sendRequestWithRoute(subRoute: String, andData json: JSON?, usingMethod method: CSHTTPMethod, withCompletionHandler completionHandler: CSBooleanCompletionHandler) {
        self.sendRequestWithRoute(subRoute, andData: json, usingMethod: method) { (json) in
            if json == nil {
                completionHandler?(false)
                return
            }
            
            completionHandler?(true)
        }
    }
    
    
    /**
    A convenience method for requests without body data
    
    - parameter 	subRoute:            subpath for the request from the host root
    - parameter     method:              HTTP method that should be used
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    private class func sendRequestWithRoute(subRoute: String, usingMethod method: CSHTTPMethod, withCompletionHandler completionHandler: CSCompletionHandler) {
        self.sendRequestWithRoute(subRoute, andData: nil, usingMethod: method, withCompletionHandler: completionHandler)
    }
    
    
    /**
    The endpoint in the client application responsible for sending an asynchronous request and converting the response to a JSON object
    
    - parameter 	subRoute:            subpath for the request from the host root
    - parameter     json:                an optional JSON object. This will become the body of the request
    - parameter     method:              HTTP method that should be used
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    private class func sendRequestWithRoute(subRoute: String, andData json: JSON?, usingMethod method: CSHTTPMethod, withCompletionHandler completionHandler: CSCompletionHandler) {
        let route = host + subRoute
        let URL = NSURL(string: route)
        if URL == nil {
            completionHandler(nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: URL!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod  = method.rawValue
        
        if json != nil {
            request.HTTPBody = try? json!.rawData(options: .PrettyPrinted)
        }
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                return completionHandler(nil)
            }
            
            var responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            var jsonError: NSError?
            let json = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
            
            if jsonError != nil {
                print(jsonError?.localizedDescription)
                return completionHandler(nil)
            }
            
            completionHandler(json)
        }).resume()
    }
//
    
    
}