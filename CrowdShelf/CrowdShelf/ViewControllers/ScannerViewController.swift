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


class ScannerViewController: BaseViewController {
    
    @IBOutlet weak var scannerView: UIView!
    
    var scanner : MTBBarcodeScanner?
    
    var scannedCodes = Set<String>()
    
    var lightOn = false {
        didSet {
            updateLight()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        scannedCodes = Set<String>()
        if scanner == nil {
            scanner = MTBBarcodeScanner(previewView: scannerView)
        }
        startScanner()
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
    
    @IBAction func toggleLight(sender: AnyObject) {
        lightOn = !lightOn
    }
    
    private func updateLight() {
        let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if avDevice.hasTorch {
            
            do {
                try avDevice.lockForConfiguration()
                
                if lightOn {
                    try avDevice.setTorchModeOnWithLevel(1.0)
                } else {
                    avDevice.torchMode = AVCaptureTorchMode.Off
                }
                
                avDevice.unlockForConfiguration()
            }
            catch let error as NSError {
                csprint(false, error.debugDescription)
            }
        }
    }
    
    /// Get retrieve information about the ISBN. If there are multiple results, let the user choose the correct alternative. 
    func retrieveInformationAboutISBN(isbn: String) {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Searching for information", inView: self.view)
        
        DataHandler.informationAboutBook(isbn, withCompletionHandler: { (information) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                activityIndicatorView.stop()
                
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
                } else {
                    MessagePopupView(message: "Could not find the book", messageStyle: .Error).show()
                }
            
            })
        })
        Analytics.addEvent("BookScanned")
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        lightOn = false
    }
}