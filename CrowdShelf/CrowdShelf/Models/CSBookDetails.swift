//
//  CSBookDetails.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON


class CSBookDetails: CSBaseModel {
    
    let description, publisher, title: String
    let numberOfRatings, numberOfPages: Int
    let authors: [String]
    let averageRating: Float
    let publishedDate: NSDate
    let thumbnailURL: NSURL
    
    required init(json: JSON) {
        self.description = json["description"].stringValue
        self.publisher = json["publisher"].stringValue
        self.title = json["title"].stringValue
        if let authors = json["authors"].arrayObject as? [String] {
            self.authors = authors
        } else {
            self.authors = []
        }
        self.numberOfRatings = json["ratingsCount"].intValue
        self.numberOfPages = json["pageCount"].intValue
        self.averageRating = json["averageRating"].floatValue
        
        let thumbnailString = json["imageLinks"]["thumbnail"].stringValue
        self.thumbnailURL = NSURL(string: thumbnailString)!
        
//        FIXME: Use date from provider
        self.publishedDate = NSDate()
    }
    
    override func toDictionary() -> [String : AnyObject] {
        return [
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
    }
}