//
//  AppDelegate.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Analytics.initialize()
//        Get stored user object if possible
        if let userValue = LocalDataHandler.getObjectForKey("user", fromFile: LocalDataFile.User) {
            print(userValue)
            User.localUser = User(value: userValue)
            Analytics.initializeUser(User.localUser!._id)

        }
        
        
        UINavigationBar.appearance().tintColor = ColorPalette.primaryColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : ColorPalette.primaryTextColor]
        self.window?.tintColor = ColorPalette.primaryColor
        UILabel.appearance().textColor = ColorPalette.primaryTextColor
        UIView.appearance().tintColor = ColorPalette.primaryColor
        Analytics.addEvent("AppLaunched")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}
