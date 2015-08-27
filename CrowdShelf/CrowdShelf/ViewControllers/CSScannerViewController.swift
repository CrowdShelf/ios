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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanner = MTBBarcodeScanner(previewView: self.scannerView)
        // Do any additional setup after loading the view, typically from a nib.
        
//        TODO: Support scanning multiple, unique barcodes at the same time.
//        Future feature for adding multiple books?
        MTBBarcodeScanner.requestCameraPermissionWithSuccess { (success) -> Void in
            if success {
                self.scanner?.startScanningWithResultBlock({ (codes) -> Void in
                    if let code = codes.first as? AVMetadataMachineReadableCodeObject {
                        UIAlertView(title: "Code scanned", message: code.stringValue, delegate: nil, cancelButtonTitle: "OK").show()
                        self.scanner?.stopScanning()
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}