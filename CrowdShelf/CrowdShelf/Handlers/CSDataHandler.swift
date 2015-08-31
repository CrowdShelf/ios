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
    
//  Procedure:
//  Check cache
//      Return chached if possible
//  Request information if needed
//  Cache the information
//  Return the information
    
    
//    TODO: Support multiple items
//    TODO: Support multiple providers
    
    /// Retrieves information about a book from Google's REST API
    class func detailsForBook(isbn: String, withCompletionHandler completionHandler: ((CSBookDetails?) -> Void)) {
        
        var bookDetails : CSBookDetails? = CSLocalDataHandler.detailsForBook(isbn)

        if bookDetails != nil {
            return completionHandler(bookDetails)
        }
        
        
        let URL = NSURL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)")
        if URL == nil {
            return completionHandler(nil)
        }
        
        let request = NSMutableURLRequest(URL: URL!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.sendRequest(request, withCompletionHandler: { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            } else if json!["totalItems"].intValue == 0 {
                println("No items returned for isbn: \(isbn)")
                return completionHandler(nil)
            } else if json!["items"][0]["volumeInfo"].error != nil {
                println(json!["items"][0]["volumeInfo"].error)
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