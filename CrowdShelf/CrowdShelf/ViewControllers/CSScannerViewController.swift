//
//  CSScannerViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 27/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation

import UIKit
import MTBBarcodeScanner

class CSScannerViewController: CSBaseViewController {
    
    @IBOutlet weak var scannerView: UIView!
    
    var scanner : MTBBarcodeScanner?
    
    var scannedCodes = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanner = MTBBarcodeScanner(previewView: self.scannerView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scannedCodes = Set<String>()
        
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
                            
                            let book = CSBook()
                            book.isbn = code.stringValue
                            self.retrieveInformationAboutBook(book)
                        }
                    }
                })
            }
        }
    }
    
    /// Get retrieve information about the ISBN. If there are multiple results, let the user choose the correct alternative. 
    func retrieveInformationAboutBook(book: CSBook) {
        CSDataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (information) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if information.count > 1 {
                    
                    self.showListWithItems(information, andCompletionHandler: { (information) -> Void in
                        book.details = information.first as? CSBookInformation
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            if book.details != nil {
                                self.performSegueWithIdentifier("ShowBook", sender: book)
                            }
                        })
                    })
                    
                } else if information.count == 1 {
                    book.details = information.first
                    self.performSegueWithIdentifier("ShowBook", sender: book)
                }
                
            })
        })
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let bookVC = navigationVC.viewControllers.first as! CSBookViewController
            bookVC.book = sender as? CSBook
        }
    }
}