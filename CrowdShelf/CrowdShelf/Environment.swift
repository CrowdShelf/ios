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
            fatalError("Host not set for environment")
        }
    }
    
    func MixpanelTracking() -> String {
        switch self {
        case CSEnvironment.Development:
            return "93ef1952b96d0faa696176aadc2fbed4"
        case CSEnvironment.Test:
            return "9f321d1662e631f2995d9b8f050c4b44"
        default:
            fatalError("Tracking token not set for environment")
        }
    }
}

let CS_ENVIRONMENT : CSEnvironment = .Development