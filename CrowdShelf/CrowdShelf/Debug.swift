//
//  Debug.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation

/**
    Print items if shouldPrint is true

    This method allows us to easily control what is written to the console using global debug variables

    - parameter shouldPrint:    A Boolean indicating whether the items should actually be printed, or not
    - parameter items:          The items to be printed
*/
public func csprint(shouldPrint: Bool, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    if !shouldPrint {
        return
    }
    
    print(NSDate())
    for item in items {
        print(item, separator, separator: "", terminator: "")
    }
    print(terminator)
}


//MARK: Data
let CS_DEBUG_NETWORK    : Bool = true
let CS_DEBUG_REALM      : Bool = true

//MARK: View Controllers
let CS_DEBUG_BOOK_VIEW  : Bool = true