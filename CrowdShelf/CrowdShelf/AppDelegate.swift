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

//        Get stored user object if possible
        if let userValue = CSLocalDataHandler.getObjectForKey("user", fromFile: CSLocalDataFile.User) {
            CSUser.localUser = CSUser(value: userValue)
        }
        
        
        Mixpanel.sharedInstanceWithToken(CS_ENVIRONMENT.MixpanelTracking())
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("AppLaunched")
        

        return true
    }

    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}
