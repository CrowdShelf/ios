//
//  CSGoogleBooksHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 16/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Responsible for communication with the Google Book REST API
public class CSGoogleBooksHandler {
    
    /**
    Retrieve information about a book based on its isbn
    
    :discussion: This is currently functioning as a standalone method in the class. It has no internal dependencies. Will be modified or moved in the future. It should support multiple information providers
    
    - parameter 	isbn:                international standard book number of a book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    - returns: 	Void
    */
    
    public class func informationForBook(isbn: String, withCompletionHandler completionHandler: ((CSBookInformation?) -> Void)) {
        self.sendRequestForQuery("isbn:\(isbn)", completionHandler: { (json) -> Void in
            if json == nil {
                return completionHandler(nil)
            } else if json!["totalItems"].intValue == 0 {
                print("No items returned for isbn: \(isbn)")
                return completionHandler(nil)
            }
            
            let bookInformation = CSBookInformation(json: json!["items"][0]["volumeInfo"])
            
            
            if let imageData = NSData(contentsOfURL: bookInformation.thumbnailURL) {
                bookInformation.thumbnailImage = UIImage(data: imageData)
            }
            
            completionHandler(bookInformation)
        })
        
        
    }
    
    private class func sendRequestForQuery(query: String, completionHandler: CSCompletionHandler) {
        let route = "https://www.googleapis.com/books/v1/volumes?q=\(query)"
        
        if let URL = NSURL(string: route) {
            let request = NSURLRequest(URL: URL)
            
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                    return completionHandler(nil)
                }
                
                let json = JSON(data: data!, options: .AllowFragments, error: nil)
                
                completionHandler(json)
            }).resume()
        } else {
            completionHandler(nil)
        }
    }
}