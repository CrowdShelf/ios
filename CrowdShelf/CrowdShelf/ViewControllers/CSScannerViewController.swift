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

class CSScannerViewController: UIViewController {
    
    @IBOutlet weak var scannerView: UIView!
    
    var scanner : MTBBarcodeScanner?
    
    var scannedCodes = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanner = MTBBarcodeScanner(previewView: self.scannerView)

        MTBBarcodeScanner.requestCameraPermissionWithSuccess { (success) -> Void in
            if success {
                self.scanner?.startScanningWithResultBlock({ (codes) -> Void in
                    if let code = codes.first as? AVMetadataMachineReadableCodeObject {
                        if !self.scannedCodes.contains(code.stringValue) {
                            self.scannedCodes.insert(code.stringValue)
                            
//                            Use an existing book if possible
                            var book = CSBook(isbn: code.stringValue, owner: CSUser.localUser!.username)
                            self.performSegueWithIdentifier("ShowBook", sender: book)
                        }
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scannedCodes = Set<String>()
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let bookVC = segue.destinationViewController as! CSBookViewController
            bookVC.book = sender as? CSBook
        }
    }
}