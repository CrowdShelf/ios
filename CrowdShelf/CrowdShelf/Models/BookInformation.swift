//
//  CSBookDetails.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

public func ==(lhs: BookInformation, rhs: BookInformation) -> Bool {
    return lhs.isbn != nil && rhs.isbn != nil && lhs.isbn!.hashValue == rhs.isbn!.hashValue
}

/// A class representing detail about a book
public class BookInformation: BaseModel, Listable, Storeable {
    
    var providerID          : String?
    var provider            : String?
    
    var isbn                : String?
    var summary             : String?
    var publisher           : String?
    var title               : String?
    var thumbnailURLString  : String?
    var numberOfPages       : NSNumber?
    var numberOfRatings     : NSNumber?
    var averageRating       : NSNumber?
    var thumbnailData       : NSData?
    var publishedDate       : NSDate?
    
    var categories  : [String] = []
    var authors     : [String] = []
        
    var subtitle : String? { return self.authors.map({$0}).joinWithSeparator(", ") }
    var image : UIImage? { return self.thumbnail }
    public var asDictionary: [String: AnyObject] {
        return self.serialize(.SQLite)
    }
    
    override public var hashValue: Int {
        return isbn != nil ? isbn!.hashValue : -1
    }
    
    var thumbnail : UIImage? {
        return UIImage(data: thumbnailData ?? NSData() )
    }
    
    public override class func ignoreProperties() -> Set<String> {
        return ["thumbnail", "image", "subtitle"]
    }
    
    public static func primaryKey() -> String {
        return "isbn"
    }
}

extension BookInformation {
    var authorsString: String? {
        return self.authors.map {$0}.joinWithSeparator(", ")
    }
}