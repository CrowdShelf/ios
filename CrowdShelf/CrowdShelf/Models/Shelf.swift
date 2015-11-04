//
//  Shelf.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 13/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


class Shelf {
    let name: String
    let filter: ((Book)->Bool)
    let parameters: [String: AnyObject]?
    
    /// All valid books in the shelf
    var books: [Book] = []
    
    var titles: [BookInformation] {
        let titles = books.filter{$0.details != nil}.map {$0.details!}
        let uniqueTitles = Set(titles)
        return Array(uniqueTitles).sort {$0.title > $1.title}
    }
    
    init(name: String, parameters: [String: AnyObject]?, filter: ((Book)->Bool)) {
        self.filter     = filter
        self.parameters = parameters
        self.name       = name
    }
}