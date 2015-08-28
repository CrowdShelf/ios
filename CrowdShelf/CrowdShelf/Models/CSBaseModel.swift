//
//  CSBaseModel.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SwiftyJSON

class CSBaseModel {
    
    init() {
        
    }
    
    convenience required init(json: JSON) {
        self.init()
        fatalError("init:json must be overridden in sub class")
    }
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init(json:JSON(dictionary))
    }
    
    
    func toDictionary() -> [String: AnyObject] {
        fatalError("toDictionary must be overridden in subclass")
    }
    
    func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
}