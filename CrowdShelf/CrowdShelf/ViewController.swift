//
//  ViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource {
    
    var contentViewControllers : [UIViewController] = []
    
    var pageViewController : UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let shelfVC = storyBoard.instantiateViewControllerWithIdentifier("ShelfViewController") as! UIViewController
        self.contentViewControllers.append(shelfVC)
        
        let scannerVC = storyBoard.instantiateViewControllerWithIdentifier("ScannerViewController") as! UIViewController
        self.contentViewControllers.append(scannerVC)
        
        self.initializePageViewController()
        self.pageViewController?.setViewControllers([self.contentViewControllers[1]], direction: .Forward, animated: false, completion: nil)
    }

    /// Instantiates a new page view controller adds it as a child view controller
    private func initializePageViewController() {
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        self.pageViewController?.didMoveToParentViewController(self)
        self.pageViewController?.view.didMoveToSuperview()
        
        self.pageViewController?.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = find(self.contentViewControllers, viewController)!
        
        if currentIndex >= self.contentViewControllers.endIndex-1 {
            return nil
        }
        

        return self.contentViewControllers[currentIndex+1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = find(self.contentViewControllers, viewController)!
        
        if currentIndex <= 0 {
            return nil
        }
        
        
        return self.contentViewControllers[currentIndex-1]
    }


}

