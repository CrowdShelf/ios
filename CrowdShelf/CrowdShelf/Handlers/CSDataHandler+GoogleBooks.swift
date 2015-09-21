//
//  CSGoogleBooksHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 16/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift


/**
    
    Adds the ability to communicate with google's books API in order to retrieve information about books
    
    The key-value coding approach should reduce the cost of adding new information providers in the future. It demands no extra classes for automatic deserialization, and is quite compact

*/

extension CSDataHandler {
    
    /**
    Retrieve information about a book from Google based on its isbn
    
    - parameter 	isbn:                international standard book number of a book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    class func informationFromGoogleAboutBook(isbn: String, withCompletionHandler completionHandler: (([String: AnyObject]?) -> Void)) {
        
        let mapping = [
            "authors": "items.volumeInfo.authors.@firstObject",
            "publisher": "items.volumeInfo.publisher.@firstObject",
            "summary": "items.volumeInfo.description.@firstObject",
            "title": "items.volumeInfo.title.@firstObject",
            "numberOfPages": "items.volumeInfo.pageCount.@firstObject",
            "numberOfRatings": "items.volumeInfo.ratingsCount.@firstObject",
            "averageRating": "items.volumeInfo.averageRating.@firstObject",
            "thumbnailURLString": "items.volumeInfo.imageLinks.thumbnail.@firstObject"
        ]
        
        
        self.sendRequestWithRoute("https://www.googleapis.com/books/v1/volumes", usingMethod: .GET, andParameters: ["q": "isbn:\(isbn)"], parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            if let resultDictionary = result as? [String: AnyObject] {
                
                var value = self.dictionaryFromDictionary(resultDictionary, usingMapping: mapping)
                value["isbn"] = isbn
                
                completionHandler(value)
            } else {
                completionHandler(nil)
            }
        }
    }
}