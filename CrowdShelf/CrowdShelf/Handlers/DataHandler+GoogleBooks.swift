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

extension DataHandler {
    
    /**
    Retrieve information about a book from Google based on its isbn
    
    - parameter 	isbn:                international standard book number of a book
    - parameter     completionHandler:   closure which will be called with the result of the request
    
    */
    
    class func informationFromGoogleAboutBook(isbn: String, withCompletionHandler completionHandler: (([BookInformation]) -> Void)) {
        
        let mapping = [
            "providerID"        : "id",
            "authors"           : "volumeInfo.authors",
            "publisher"         : "volumeInfo.publisher",
            "summary"           : "volumeInfo.description",
            "title"             : "volumeInfo.title",
            "numberOfPages"     : "volumeInfo.pageCount",
            "numberOfRatings"   : "volumeInfo.ratingsCount",
            "averageRating"     : "volumeInfo.averageRating",
            "thumbnailURLString": "volumeInfo.imageLinks.thumbnail",
            "categories"        : "volumeInfo.categories"
        ]
        
        
        self.sendRequestWithRoute("https://www.googleapis.com/books/v1/volumes", usingMethod: .GET, andParameters: ["q": "isbn:\(isbn)"], parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            var informationObjects: [BookInformation] = []
            
            if let resultDictionary = result as? [String: AnyObject] {
                if let itemArray = resultDictionary["items"] as? [[String: AnyObject]] {
                    for itemInfo in itemArray {
                        
                        var value = self.dictionaryFromDictionary(itemInfo, usingMapping: mapping)
                        value["isbn"] = isbn
                        value["provider"] = "google"
                        
                        informationObjects.append(BookInformation(value: value))
                        
                    }
                }
            }
            
            completionHandler(informationObjects)
        }
    }
}