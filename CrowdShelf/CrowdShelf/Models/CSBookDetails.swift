//
//  CSBookDetails.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A class representing detail about a book
public class CSBookDetails: CSBaseModel {
    
    let description, publisher, title: String
    let numberOfRatings, numberOfPages: Int
    let authors: [String]
    let averageRating: Float
    let publishedDate: NSDate
    let thumbnailURL: NSURL
    var thumbnailImage : UIImage?
    
    
    /**
    Create a new book detail instance populated with data from a JSON object 
    
    :discussion: Useful when communicating with external systems
    
    :param:     json   json object containing data about a user
    
    :returns:   A new book details instance
    */
    
    required public init(json: JSON) {
        self.description = json["description"].stringValue
        self.publisher = json["publisher"].stringValue
        self.title = json["title"].stringValue
        self.numberOfRatings = json["ratingsCount"].intValue
        self.numberOfPages = json["pageCount"].intValue
        self.averageRating = json["averageRating"].floatValue
        
        let thumbnailString = json["imageLinks"]["thumbnail"].stringValue
        self.thumbnailURL = NSURL(string: thumbnailString)!
        
//        TODO: Get NSData form SwiftyJSON
        if json.dictionaryObject != nil {
            if let thumbnailData = json.dictionaryObject!["thumbnailImage"] as? NSData {
                self.thumbnailImage = UIImage(data: thumbnailData)
            }
        }
        
        if let authors = json["authors"].arrayObject as? [String] {
            self.authors = authors
        } else {
            self.authors = []
        }
        
//        FIXME: Use date from provider
        self.publishedDate = NSDate()
    }
    
    
    /**
    Create a dictionary containing all information the instance contains
    
    :returns:   A dictionary containing all information the instance contains
    */
    
    override func toDictionary() -> [String : AnyObject] {
        var dictionary : [String: AnyObject] = [
            "description": self.description,
            "publisher": self.publisher,
            "title": self.title,
            "authors": self.authors,
            "numberOfRatings": self.numberOfRatings,
            "numberOfPages": self.numberOfPages,
            "averageRating": self.averageRating,
            "publishedDate": (self.publishedDate.timeIntervalSince1970 * 1000),
            "imageLinks": [
                "thumbnail": self.thumbnailURL.absoluteString!
            ]
        ]
        
        if self.thumbnailImage != nil {
            dictionary["thumbnailImage"] = UIImageJPEGRepresentation(self.thumbnailImage!, 0.7)
            
        }
        
        return dictionary
    }
}