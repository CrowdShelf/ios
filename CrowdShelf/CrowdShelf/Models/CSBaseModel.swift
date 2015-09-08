//
//  CSBaseModel.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON


/// The base model which all other data models extends
public class CSBaseModel {
    
    init() {}
    
    /**
    Create a new instance populated with data from a JSON object. Useful when communicating with external systems
    
    :param:     json   json object containing data about a book
    
    :returns:   A new instance
    */
    
    convenience required public init(json: JSON) {
        self.init()
        fatalError("init:json must be overridden in sub class")
    }
    
    
    /**
    Create a new instance populated with data from a dictionary
    
    :param:     dictionary   dictionary object containing data about a book
    
    :returns:   A new instance
    */
    
    convenience public init(dictionary: [String: AnyObject]) {
        self.init(json:JSON(dictionary))
    }
    
    
    /**
    Create a dictionary containing all information the instance contains
    
    :returns:   A dictionary containing all information the instance contains
    */
    
    func toDictionary() -> [String: AnyObject] {
        fatalError("toDictionary must be overridden in subclass")
    }
    
    
    /**
    Create a JSON object containing all information the instance contains
    
    :returns:   A JSON object containing all information the instance contains
    */
    
    func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
}