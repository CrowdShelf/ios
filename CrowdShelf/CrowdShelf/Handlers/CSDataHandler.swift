//
//  CSDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

enum CSHTTPMethod : String {
    case GET    = "GET"
    case POST   = "POST"
    case PUT    = "PUT"
}

typealias CSPutCompletionHandler = ((Bool)->Void)?
typealias CSPostCompletionHandler = CSPutCompletionHandler
typealias CSCompletionHandler = ((JSON?)->Void)

class CSDataHandler {
    
    class var host : String {
        return "https://crowdshelf.herokuapp.com/api"
    }
    
    /// Retrieves information about a book from Google's REST API
    class func detailsForBook(isbn: String, withCompletionHandler completionHandler: ((CSBookDetails?) -> Void)) {
        
        var bookDetails : CSBookDetails? = CSLocalDataHandler.detailsForBook(isbn)
        if bookDetails != nil {
            return completionHandler(bookDetails)
        }
        
        self.sendGetRequest("https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            } else if json!["totalItems"].intValue == 0 {
                println("No items returned for isbn: \(isbn)")
                return completionHandler(nil)
            }
            
            bookDetails = CSBookDetails(json: json!["items"][0]["volumeInfo"])
            
            if bookDetails?.thumbnailURL != nil {
                let imageData = NSData(contentsOfURL: bookDetails!.thumbnailURL)
                if imageData != nil {
                    bookDetails?.thumbnailImage = UIImage(data: imageData!)
                }
            }
            
            CSLocalDataHandler.setDetails(bookDetails!, forBook: isbn)
            
            completionHandler(bookDetails)
        }
    }
    
    
    class func addBook(book: CSBook, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        let route = host+"/book"
        self.sendPutRequest(route, json: book.toJSON(), withCompletionHandler: completionHandler)
    }
    
    class func getBook(isnb: String, owner: CSUser, withCompletionHandler completionHandler: ((CSBook?)->Void)) {
        let route = host+"/book/\(isnb)/\(owner.name)"
        self.sendGetRequest(route, withCompletionHandler: { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSBook(json: json!))
        })
    }
    
    class func addRenter(renter: CSUser, book: CSBook, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        let route = host+"/book/\(book.isbn)/\(book.owner)/addrenter"
        self.sendPutRequest(route, json: renter.toJSON(), withCompletionHandler: completionHandler)
    }
    
    class func removeRenter(renter: CSUser, book: CSBook, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        let route = host+"/book/\(book.isbn)/\(book.owner)/removerenter"
        self.sendPutRequest(route, json: renter.toJSON(), withCompletionHandler: completionHandler)
    }
    
    class func createCrowd(crowd: CSCrowd, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        let route = host+"/crowd"
        self.sendPutRequest(route, json: crowd.toJSON(), withCompletionHandler: completionHandler)
    }
    
    class func getCrowd(crowdID: String, withCompletionHandler completionHandler: ((CSCrowd?)->Void)) {
        let route = host+"/crowd/\(crowdID)"
        self.sendGetRequest(route, withCompletionHandler: { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSCrowd(json: json!))
        })
    }
    
    class func addCrowdMember(crowd: CSCrowd, member: CSUser, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        let route = host+"/crowd/\(crowd.id)/addememeber"
        self.sendPutRequest(route, json: member.toJSON(), withCompletionHandler: completionHandler)
    }
    
    class func removeCrowdMember(crowd: CSCrowd, member: CSUser, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        let route = host+"/crowd/\(crowd.id)/removemember"
        self.sendPutRequest(route, json: member.toJSON(), withCompletionHandler: completionHandler)
    }
    
    class func getUser(name: String, withCompletionHandler completionHandler: ((CSUser?)->Void)) {
        let route = host+"/user/\(name)"
        self.sendGetRequest(route, withCompletionHandler: { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSUser(json: json!))
        })
    }
    
    
    
    
//    MARK: - Private
    
    private class func sendGetRequest(route: String, withCompletionHandler completionHandler: CSCompletionHandler) {
        self.sendRequestWithRoute(route, andData: nil, usingMethod: .GET) { (json) -> Void in
            completionHandler(json)
        }
    }
    
    private class func sendPutRequest(route: String, json: JSON, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        self.sendRequestWithRoute(route, andData: json, usingMethod: .PUT) { (json) -> Void in
            completionHandler?(true)
        }
    }
    
    private class func sendPostRequest(route: String, json: JSON, withCompletionHandler completionHandler: CSPutCompletionHandler) {
        self.sendRequestWithRoute(route, andData: json, usingMethod: .POST) { (json) -> Void in
            completionHandler?(true)
        }
    }
    
    /// The endpoint in the client application responsible for sending an async request and converting the response to a JSON object
    private class func sendRequestWithRoute(route: String, andData json: JSON?, usingMethod method: CSHTTPMethod, withCompletionHandler completionHandler: CSCompletionHandler) {
        
        let URL = NSURL(string: route)
        if URL == nil {
            completionHandler(nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: URL!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod  = method.rawValue
        
        if method != .GET {
            request.HTTPBody = json!.rawData(options: .PrettyPrinted, error: nil)
        }
        
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                completionHandler(nil)
                return
            }
            
            var jsonError: NSError?
            let json = JSON(data: data, options: .MutableContainers, error: &jsonError)
            
            if jsonError != nil {
                println(jsonError)
            }
            
            completionHandler(json)
        }).resume()
    }
//
    
    
}