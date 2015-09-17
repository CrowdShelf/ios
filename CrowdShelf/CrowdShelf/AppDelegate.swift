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

        if let username = CSLocalDataHandler.getObjectForKey("username", fromFile: CSLocalDataFile.User) as? String {
            CSUser.localUser = CSUser(username: username)
            
//            CSDataHandler.getUser(username, withCompletionHandler: { (user) -> Void in
//                CSUser.localUser = user!
//            })
        } else {
            self.showUsernameInput()
        }
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}

extension AppDelegate: UIAlertViewDelegate {
    func showUsernameInput() {
        let alertView = UIAlertView(title: "Create user", message: "Please tell us your username :)", delegate: self, cancelButtonTitle: "Let me in")
        alertView.alertViewStyle = .PlainTextInput
        alertView.tag = 616
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.tag != 616 {
            if buttonIndex == alertView.cancelButtonIndex {
                self.showUsernameInput()
            }
            return
        }
        
        let username = alertView.textFieldAtIndex(0)!.text!
            
        if username.characters.count != 0 {
            CSLocalDataHandler.setObject(username, forKey: "username", inFile: CSLocalDataFile.User)
            
            CSDataHandler.getUser(username, withCompletionHandler: { (user) -> Void in
                if user == nil {
                    CSUser.localUser = CSUser(username: username)
                } else {
                    CSUser.localUser = user!
                }
            })
            
        } else {
            UIAlertView(title: "Please provide a username", message: "A username is necessary in order to save books. If you choose not to provide one now, restart the app to redeem you mistakes", delegate: self, cancelButtonTitle: "I'll come up with a username", otherButtonTitles: "Let me in anyway").show()
        }
    }
}

