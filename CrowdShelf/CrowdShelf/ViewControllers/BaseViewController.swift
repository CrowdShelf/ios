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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoginIfLoggedOut", name: Notification.LocalUserUpdated, object: nil)
    }
    
    func showLoginIfLoggedOut() {
        if User.localUser == nil {
            self.showLogin()
        }
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    func showListWithItems(items: [Listable], andCompletionHandler completionHandler: (([Listable]) -> Void)) -> ListViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let listVC = storyboard.instantiateViewControllerWithIdentifier("ListViewController") as! ListViewController
        
        listVC.listData = items
        listVC.completionHandler = completionHandler
        
        self.presentViewController(listVC, animated: true, completion: nil)
        
        return listVC
    }
    
    func showCollectionWithItems(items: [Collectable], andCompletionHandler completionHandler: (([Collectable]) -> Void)) -> CollectionViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let listVC = storyboard.instantiateViewControllerWithIdentifier("CollectionViewController") as! CollectionViewController
        
        listVC.collectionData = items
        listVC.completionHandler = completionHandler
        
        self.presentViewController(listVC, animated: true, completion: nil)
        
        return listVC
    }
    
//    MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let bookVC = navigationVC.viewControllers.first as! BookViewController
            
            if let collectableCell = sender as? CollectableCell {
                bookVC.book = collectableCell.collectable as? Book
            } else if let book = sender as? Book {
                bookVC.book = book
            }
        }
    }
    
}