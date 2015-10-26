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
    
    class func throttle( delay:NSTimeInterval, queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action: (()->()) ) -> ()->() {
        
        var wait = false

        return {
            if !wait {
                wait = true
                
                action()
                
                let delayTime = Int64(delay * Double(NSEC_PER_SEC))
                dispatch_after( dispatch_time(DISPATCH_TIME_NOW, delayTime) , queue ) {
                    wait = false
                }
            }
        }
    }
    
    class func debounce( delay:NSTimeInterval, queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action: (()->()) ) -> ()->() {
        var lastFireTime:dispatch_time_t = 0
        let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
        
        return {
            lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    dispatchDelay
                ),
                queue) {
                    let now = dispatch_time(DISPATCH_TIME_NOW,0)
                    let when = dispatch_time(lastFireTime, dispatchDelay)
                    if now >= when {
                        action()
                    }
            }
        }
    }
    
}