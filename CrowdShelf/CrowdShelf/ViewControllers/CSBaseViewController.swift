//
//  CSBaseViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 23/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class CSBaseViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CSUser.localUser == nil {
            self.showLogin()
        }
    }
    
    func showLogin() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! CSLoginViewController
        
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    func showListWithItems(items: [Listable], andCompletionHandler completionHandler: (([Listable]) -> Void)) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let listVC = storyboard.instantiateViewControllerWithIdentifier("ListViewController") as! CSListViewController
        
        listVC.listData = items
        listVC.completionHandler = completionHandler
        
        self.presentViewController(listVC, animated: true, completion: nil)
    }
    
}