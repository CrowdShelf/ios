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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scanner = MTBBarcodeScanner(previewView: self.scannerView)
        self.scannedCodes = Set<String>()
        
//        TODO: Support scanning multiple, unique barcodes at the same time.
//        Future feature for adding multiple books?
        MTBBarcodeScanner.requestCameraPermissionWithSuccess { (success) -> Void in
            if success {
                self.scanner?.startScanningWithResultBlock({ (codes) -> Void in
                    if let code = codes.first as? AVMetadataMachineReadableCodeObject {
                        if !self.scannedCodes.contains(code.stringValue) {
                            self.scannedCodes.insert(code.stringValue)
                            self.performSegueWithIdentifier("ShowBook", sender: code.stringValue)
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let bookVC = segue.destinationViewController as! CSBookViewController
            bookVC.book = CSBook(isbn: sender as! String)
        }
    }
    
    
}