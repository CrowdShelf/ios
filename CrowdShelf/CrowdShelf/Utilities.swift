//
//  Utilities.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 25/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


class Utilities {
    
    class func delayDispatchInQueue(queue: dispatch_queue_t, delay: NSTimeInterval, block: (()->Void)) {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            block()
        })
    }
    
}