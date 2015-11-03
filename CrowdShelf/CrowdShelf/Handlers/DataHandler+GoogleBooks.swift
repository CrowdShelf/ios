//
//  CSGoogleBooksHandler.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 16/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


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
    
    internal class func informationFromGoogleAboutBook(isbn: String, withCompletionHandler completionHandler: (([BookInformation]) -> Void)) {
        
        self.sendRequestWithRoute("https://www.googleapis.com/books/v1/volumes", usingMethod: .GET, andParameters: ["q": "isbn:\(isbn)"], parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            var informationObjects: [BookInformation] = []
            
            if let resultDictionary = result as? [String: AnyObject] {
                if let itemArray = resultDictionary["items"] as? [[String: AnyObject]] {
                    for itemInfo in itemArray {
                        
                        var value = self.dictionaryFromDictionary(itemInfo, usingMapping: mapping())
                        value["provider"] = "google"
                        value["isbn"] = self.isbnFromItemInfoDictionary(itemInfo)
                        
                        informationObjects.append(BookInformation(dictionary: value))
                        
                    }
                }
            }
            
            completionHandler(informationObjects)
        }
    }
    
    internal class func resultsFromGoogleForQuery(query: String, withCompletionHandler completionHandler: (([BookInformation]) -> Void)) {
        
        self.sendRequestWithRoute("https://www.googleapis.com/books/v1/volumes", usingMethod: .GET, andParameters: ["q": "\(query)", "maxResults": 20], parameterEncoding: .URL) { (result, isSuccess) -> Void in
            
            var informationObjects: [BookInformation] = []
            
            if let resultDictionary = result as? [String: AnyObject] {
                if let itemArray = resultDictionary["items"] as? [[String: AnyObject]] {
                    itemArray.forEach({ (itemInfo) -> () in
                        var value = self.dictionaryFromDictionary(itemInfo, usingMapping: mapping())
                        value["provider"] = "google"
                        value["isbn"] = self.isbnFromItemInfoDictionary(itemInfo)
                        
                        informationObjects.append(BookInformation(dictionary: value))
                    })
                }
            }

            completionHandler(informationObjects)
        }
    }
    
    private class func isbnFromItemInfoDictionary(dictionary: [String: AnyObject]) -> String? {
        if let volumeInfo = dictionary["volumeInfo"] as? [String: AnyObject] {
            if let industryIdentifiers = volumeInfo["industryIdentifiers"] as? [[String: String]] {
               
                for identifier in industryIdentifiers {
                    if identifier["type"] == "ISBN_10" || identifier["type"] == "ISBN_13" {
                        return identifier["identifier"]
                    }
                }
            
            }
        }
        
        return nil
    }
    
    internal class func mapping() -> [String: String] {
        return [
            "providerID"        : "id",
            "authors"           : "volumeInfo.authors",
            "publisher"         : "volumeInfo.publisher",
            "summary"           : "volumeInfo.description",
            "title"             : "volumeInfo.title",
            "numberOfPages"     : "volumeInfo.pageCount",
            "numberOfRatings"   : "volumeInfo.ratingsCount",
            "averageRating"     : "volumeInfo.averageRating",
            "thumbnailURLString": "volumeInfo.imageLinks.thumbnail",
            "categories"        : "volumeInfo.categories",
            "isbn"              : "volumeInfo.industryIdentifiers.identifier.@firstObject"
        ]
    }
}