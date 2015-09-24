//
//  Environment.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 18/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation

enum CSEnvironment {
    case Development
    case Production
    case Test
    
    func hostString() -> String {
        switch self {
        case CSEnvironment.Development:
            return "https://crowdshelf-dev.herokuapp.com/api"
        case CSEnvironment.Test:
            return "https://crowdshelf.herokuapp.com/api"
        default:
            fatalError("Host not configured")
        }
    }
}

let CS_ENVIRONMENT : CSEnvironment = .Development