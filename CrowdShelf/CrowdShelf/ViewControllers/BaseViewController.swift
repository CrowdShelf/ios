//
//  CSBaseViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 23/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class BaseViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if User.localUser == nil {
            self.showLogin()
        }
    }
    
    func showLogin() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    func showListWithItems(items: [Listable], andCompletionHandler completionHandler: (([Listable]) -> Void)) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let listVC = storyboard.instantiateViewControllerWithIdentifier("ListViewController") as! ListViewController
        
        listVC.listData = items
        listVC.completionHandler = completionHandler
        
        self.presentViewController(listVC, animated: true, completion: nil)
    }
    
}