//
//  Analytics.swift
//  CrowdShelf
//
//  Created by Maren Parnas Gulnes on 29.09.15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import Mixpanel
class Analytics{

    class func initialize() {
        Mixpanel.sharedInstanceWithToken(CS_ENVIRONMENT.MixpanelTracking())
        Mixpanel.sharedInstance().people.set(["Categories": []])
        
    }
    class func initializeUser(id: String) {
        Mixpanel.sharedInstance().identify(id)
    }

    
    //Adds a spesific mixpanel event, eventName, to a function
    class func addEvent(eventName: String){
        Mixpanel.sharedInstance().track(eventName)
    }
    
    //Adds an event with properties
    class func addBookProperties(book: Book){
        let categories = book.details?.categories.map {$0.content as! String}
        let list:NSArray = categories!
         Mixpanel.sharedInstance().people.append(["Categories":  list])
    }
    

}
