//
//  Environment.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 18/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation



let CS_ENVIRONMENT : CSEnvironment = .Development



enum CSEnvironment {
    case Development, Production, Test
    
    func hostString() -> String {
        switch self {
        case .Development:
            return "https://crowdshelf-dev.herokuapp.com/api/"
        case .Test:
            return "https://crowdshelf.herokuapp.com/api/"
        default:
            fatalError("Host not set for environment")
        }
    }
    
    func MixpanelTracking() -> String {
        switch self {
        case .Development:
            return "93ef1952b96d0faa696176aadc2fbed4"
        case .Test:
            return "9f321d1662e631f2995d9b8f050c4b44"
        default:
            fatalError("Tracking token not set for environment")
        }
    }
}