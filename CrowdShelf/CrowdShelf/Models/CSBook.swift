//
//  Book.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

public func ==(lhs: CSBook, rhs: CSBook) -> Bool {
    return lhs.isbn == rhs.isbn
}

/// A class representing a book
public class CSBook: CSBaseModel, Equatable {

    let isbn : String
    let owner : String?
    var avaliableForRent: Int
    var rentedTo : [String]
    var numberOfCopies: Int
    
    var details : CSBookInformation?
    
    /// The bare-bones workhorse of the book initalizers
    init(isbn: String, owner: String?, avaliableForRent: Int, rentedTo: [String], numberOfCopies: Int) {
        self.isbn = isbn
        self.owner = owner
        self.avaliableForRent = avaliableForRent
        self.rentedTo = rentedTo
        self.numberOfCopies = numberOfCopies
    }
    
    
    /**
    Create a new book instance with a provided owner
    
    :param:     isbn    international standard book number for a book
    :param:     owner   username of the owner of the book
    
    :returns:   A new book instance
    */
    
    convenience public init(isbn: String, owner: String?) {
        self.init(isbn:             isbn,
                  owner:            owner,
                  avaliableForRent: 1,
                  rentedTo:         [],
                  numberOfCopies:   1)        
    }
    
    
    /**
    Create a new book instance populated with data from a JSON object. Useful when communicating with external systems
    
    :param:     json   json object containing data about a book
    
    :returns:   A new book instance
    */

    convenience required public init(json: JSON) {
        self.init(isbn:             json["isbn"].stringValue,
                  owner:            json["owner"].string,
                  avaliableForRent: json["numAvailableForRent"].intValue,
                  rentedTo:         json["rentedTo"].arrayObject as! [String],
                  numberOfCopies:   json["numberOfCopies"].intValue)
    }
    
    
    /**
    Create a dictionary containing all information the instance contains
    
    :returns:   A dictionary containing all information the instance contains
    */
    
    override func toDictionary() -> [String : AnyObject] {
        return [
            "isbn": self.isbn,
            "owner": self.owner!,
            "numAvailableForRent": self.avaliableForRent,
            "numberOfCopies": self.numberOfCopies,
            "rentedTo": self.rentedTo
        ]
    }
}