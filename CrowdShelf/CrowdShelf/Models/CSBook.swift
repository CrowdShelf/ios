//
//  Book.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

class CSBook: CSBaseModel {
    
    let isbn : String
    let owner : String
    var avaliableForRent: Int
    var rentedTo : [String]
    var numberOfCopies: Int
    
    var details : CSBookDetails?
    
    /// The bare-bones workhorse of the book initalizers
    init(isbn: String, owner: String, avaliableForRent: Int, rentedTo: [String], numberOfCopies: Int) {
        self.isbn = isbn
        self.owner = owner
        self.avaliableForRent = avaliableForRent
        self.rentedTo = rentedTo
        self.numberOfCopies = numberOfCopies
    }
    
    /// Useful when registering a single copy of a new book
    convenience init(isbn: String) {
        self.init(isbn:             isbn,
                  owner:            "localUser",
                  avaliableForRent: 1,
                  rentedTo:         [],
                  numberOfCopies:   1)        
    }
    
    /// Useful when registering a multipe copies of a new book
    convenience init(isbn: String, numberOfCopies: Int) {
        self.init(isbn:             isbn,
                  owner:            "localUser",
                  avaliableForRent: numberOfCopies,
                  rentedTo:         [],
                  numberOfCopies:   numberOfCopies)
    }
    
    /// Populate with data from a JSON object. Useful when communicating with the backend
    convenience required init(json: JSON) {
        self.init(isbn:             json["isbn"].stringValue,
                  owner:            json["owner"].stringValue,
                  avaliableForRent: json["avaliableForRent"].intValue,
                  rentedTo:         json["rentedTo"].arrayObject as! [String],
                  numberOfCopies:   json["numberOfCopies"].intValue)
    }
    
    
    override func toDictionary() -> [String : AnyObject] {
        var dictionary : [String: AnyObject] = [
            "isbn": self.isbn,
            "owner": self.owner,
            "avaliableForRent": self.avaliableForRent,
            "numberOfCopies": self.numberOfCopies,
            "rentedTo": self.rentedTo
        ]

        return dictionary
    }
}