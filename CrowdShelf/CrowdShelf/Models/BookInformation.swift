//
//  CSBookDetails.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

public func ==(lhs: BookInformation, rhs: BookInformation) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/// A class representing detail about a book
public class BookInformation: BaseModel, Listable, Collectable, Hashable {
    
    dynamic var providerID                  = ""
    dynamic var provider                    = ""
    
    dynamic var isbn                        = ""
    dynamic var summary                     = ""
    dynamic var publisher                   = ""
    dynamic var title                       = ""
    dynamic var thumbnailURLString          = ""
    dynamic var numberOfPages: Int          = 0
    dynamic var numberOfRatings: Int        = 0
    dynamic var averageRating: Float        = 0.0
    dynamic var thumbnailData: NSData       = NSData()
    dynamic var publishedDate: NSDate       = NSDate(timeIntervalSince1970: 0)
    var categories                          = List<RLMWrapper>()
    var authors                             = List<RLMWrapper>()
    
//    Listable
    var subtitle : String? { return self.authors.map({$0.content as! String}).joinWithSeparator(", ") }
    var image : UIImage? { return self.thumbnail }
    
    
    var thumbnail : UIImage? {
        return thumbnailData.length > 0 ? UIImage(data: thumbnailData) : nil
    }
    
//    MARK: Realm Object
    override public static func ignoredProperties() -> [String] {
        return ["thumbnail"]
    }
    
    override public static func primaryKey() -> String {
        return "isbn"
    }
    
//    MARK: Serializable Object
    override func serializedValueForProperty(property: String) -> AnyObject? {
        if property == "authors" {
            return self.authors.map {$0.content}
        }
        
        return nil
    }
}

extension BookInformation {
    var authorsString: String? {
        return self.authors.map {$0.stringValue!}.joinWithSeparator(", ")
    }
}