//
//  CSUser.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

// FIXME: Ugly, temporary mimic of apples local user
private var _localUser : CSUser?

/// Dummy class until model is defined
public class CSUser: CSBaseModel {
    
    let username: String
    var booksOwned: [CSBook]
    var booksRented: [CSBook]
    var crowds: [CSCrowd]
    
    var books: [CSBook] {
        return self.booksOwned + self.booksRented
    }
    
    /// The user that is currently authenticated
    class var localUser : CSUser? {
        get {
            return _localUser
        }
        set {
            _localUser = newValue
            NSNotificationCenter.defaultCenter().postNotificationName(CSDataHandlerNotification.LocalUserUpdated, object: nil)
        }
    }
    
    init(username: String, booksOwned: [CSBook], booksRented: [CSBook], crowds: [CSCrowd]) {
        self.username = username
        self.booksOwned = booksOwned
        self.booksRented = booksRented
        self.crowds = crowds
        
        super.init()
    }
    
    
    /**
    Create a new user instance
    
    :param:     username    username of the user
    
    :returns:   A new user instance
    */
    
    convenience public init(username: String) {
        self.init(username: username,
                  booksOwned: [],
                  booksRented: [],
                  crowds: [])
    }
    
    
    /**
    Create a new user instance populated with data from a JSON object. Useful when communicating with external systems
    
    :param:     json   json object containing data about a user
    
    :returns:   A new user instance
    */
    
    convenience required public init(json: JSON) {
        let booksOwned : [CSBook] = map(json["booksOwned"].arrayValue) {CSBook(json: $0)}
        let booksRented : [CSBook] = map(json["booksRented"].arrayValue) {CSBook(json: $0)}
        let crowds : [CSCrowd] = map(json["crowds"].arrayValue) {CSCrowd(json: $0)}
        
        self.init(username:     json["username"].stringValue,
                  booksOwned:   booksOwned,
                  booksRented:  booksRented,
                  crowds:       crowds)
    }
    
    
    /**
    Create a dictionary containing all information the instance contains
    
    :returns:   A dictionary containing all information the instance contains
    */
    
    override func toDictionary() -> [String : AnyObject] {
        return [
            "username": self.username,
            "booksOwned": self.booksOwned.map {$0.toDictionary()},
            "booksRented": self.booksRented.map {$0.toDictionary()},
            "crowds": self.crowds.map {$0.toDictionary()}
        ]
    }
}