//
//  CSScannerViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import Mixpanel
import UIKit
import MTBBarcodeScanner

class ScannerViewController: BaseViewController {
    
    @IBOutlet weak var scannerView: UIView!
    
    var scanner : MTBBarcodeScanner?
    
    var scannedCodes = Set<String>()
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scannedCodes = Set<String>()
        if self.scanner == nil {
            self.scanner = MTBBarcodeScanner(previewView: self.scannerView)
        }
        self.startScanner()
    }
    
    func stopScanner() {
        self.scanner?.stopScanning()
    }
    
    func startScanner() {
        MTBBarcodeScanner.requestCameraPermissionWithSuccess { (success) -> Void in
            if success {
                self.scanner?.startScanningWithResultBlock({ (codes) -> Void in
                    if let code = codes.first as? AVMetadataMachineReadableCodeObject {
                        if !self.scannedCodes.contains(code.stringValue) {
                            self.scannedCodes.insert(code.stringValue)
                            
                            self.retrieveInformationAboutISBN(code.stringValue)
                        }
                    }
                })
            }
        }
    }
    
    /// Get retrieve information about the ISBN. If there are multiple results, let the user choose the correct alternative. 
    func retrieveInformationAboutISBN(isbn: String) {
        DataHandler.informationAboutBook(isbn, withCompletionHandler: { (information) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let book = Book()
                book.isbn = isbn
                
                if information.count > 1 {
                    
                    self.showListWithItems(information, andCompletionHandler: { (information) -> Void in
                        book.details = information.first as? BookInformation
                        
                        self.dismissViewControllerAnimated(false, completion: nil)
                        if book.details != nil {
                            self.performSegueWithIdentifier("ShowBook", sender: book)
                        }
                    })
                    
                } else if information.count == 1 {
                    book.details = information.first
                    self.performSegueWithIdentifier("ShowBook", sender: book)
                }
                
            })
        })
        Mixpanel.sharedInstanceWithToken(CS_ENVIRONMENT.MixpanelTracking())
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("BookScanned")
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let bookVC = navigationVC.viewControllers.first as! BookViewController
            bookVC.book = sender as? Book
        }
    }
}