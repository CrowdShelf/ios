//
//  CSBookDetails.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

public func ==(lhs: BookInformation, rhs: BookInformation) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/// A class representing detail about a book
public class BookInformation: BaseModel, Listable, Storeable {
    
    dynamic var providerID          : String?
    dynamic var provider            : String?
    
    dynamic var isbn                : String?
    dynamic var summary             : String?
    dynamic var publisher           : String?
    dynamic var title               : String?
    dynamic var thumbnailURLString  : String?
    dynamic var numberOfPages       : NSNumber?
    dynamic var numberOfRatings     : NSNumber?
    dynamic var averageRating       : NSNumber?
    dynamic var thumbnailData       : NSData?
    dynamic var publishedDate       : NSDate?
    
    var categories  : [String] = []
    var authors     : [String] = []
        
    var subtitle : String? { return self.authors.map({$0}).joinWithSeparator(", ") }
    var image : UIImage? { return self.thumbnail }
    var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }
    
    var thumbnail : UIImage? {
        return UIImage(data: thumbnailData ?? NSData() )
    }
}

extension BookInformation {
    var authorsString: String? {
        return self.authors.map {$0}.joinWithSeparator(", ")
    }
}

extension BookInformation {
    
    class var columnDefinitions: [String: [String]] {
        return [
            "isbn"                  : ["TEXT", "PRIMARY KEY"],
            "providerID"            : ["TEXT", "NOT NULL"],
            "provider"              : ["TEXT", "NOT NULL"],
            "title"                 : ["TEXT"],
            "summary"               : ["TEXT"],
            "publisher"             : ["TEXT"],
            "thumbnailURLString"    : ["TEXT"],
            "numberOfPages"         : ["INT"],
            "numberOfRatings"       : ["INT"],
            "averageRating"         : ["REAL"],
            "thumbnailData"         : ["BLOB"],
            "publishedDate"         : ["DATE"],
            "authors"               : ["TEXT"],
            "categories"            : ["TEXT"],
        ]
    }

}