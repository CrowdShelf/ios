//
//  CSDataHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

class CSDataHandler {
    
//    TODO: Support multiple items
//    TODO: Support multiple providers
    /// Retrieves information from googles REST API
    class func detailsForBook(isbn: String, withCompletionHandler completionHandler: ((CSBookDetails?) -> Void)) {
        let URL = NSURL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)")
        
        if URL == nil {
            return completionHandler(nil)
        }
        
        let request = NSMutableURLRequest(URL: URL!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.sendRequest(request, withCompletionHandler: { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            }
            
            completionHandler(CSBookDetails(json: json!["items"][0]["volumeInfo"]))
        })
    }
    
    /// The endpoint in the client application responsible for sending a request and converting the response to a JSON object
    private class func sendRequest(request: NSURLRequest, withCompletionHandler completionHandler: ((JSON?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println(error)
                return completionHandler(nil)
            }
            
            var jsonError: NSError?
            let json = JSON(data: data, options: .MutableContainers, error: &jsonError)
            
            if jsonError != nil {
                println(jsonError)
                return completionHandler(nil)
            }
            
            completionHandler(json)
        }).resume()
    }
    
}