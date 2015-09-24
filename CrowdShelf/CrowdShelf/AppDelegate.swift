//
//  AppDelegate.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        let localUser = CSUser(value: [
//            "username": "oyvindkg",
//            "name": "Øyvind Grimnes",
//            "email": "oyvindkg@yahoo.com",
//            "_id": "5602a211a0913f110092352a"
//        ])
//        
//        CSUser.localUser = localUser
        
        if let userValue = CSLocalDataHandler.getObjectForKey("user", fromFile: CSLocalDataFile.User) {
            CSUser.localUser = CSUser(value: userValue)
        }
        
        Mixpanel.sharedInstanceWithToken("93ef1952b96d0faa696176aadc2fbed4")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        

        return true
    }

    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}
