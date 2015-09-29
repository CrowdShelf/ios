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
    
    //Adds a spesific mixpanel event, eventName, to a function
    
    
    class func addEvent(eventName: String){
        Mixpanel.sharedInstanceWithToken(CS_ENVIRONMENT.MixpanelTracking())
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track(eventName)
    }
    class func addBook(book: Book){
        
    }
}
