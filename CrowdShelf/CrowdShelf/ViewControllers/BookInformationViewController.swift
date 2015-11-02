//
//  CSBookInformationViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 23/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class BookInformationViewController: BaseViewController {
    
    @IBOutlet weak var authorsLabel: UILabel?
    @IBOutlet weak var publisherLabel: UILabel?
    @IBOutlet weak var isbnLabel: UILabel?
    @IBOutlet weak var pageCountLabel: UILabel?
    @IBOutlet weak var thumbnailImage: UIImageView?
    @IBOutlet weak var summaryTextArea: UITextView?
    
    @IBOutlet weak var backgroundImage: UIImageView?
    var bookInformation: BookInformation? {
        didSet {
            self.updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.thumbnailImage?.layer.borderWidth = 1
        self.thumbnailImage?.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.updateView()
    }
    
    func updateView() {
        self.title = self.bookInformation?.title
        self.authorsLabel?.text = self.bookInformation?.authors.joinWithSeparator(", ")
        self.publisherLabel?.text = self.bookInformation?.publisher
        self.isbnLabel?.text = self.bookInformation?.isbn
        self.pageCountLabel?.text = "\(self.bookInformation?.numberOfPages ?? 0)"
        self.thumbnailImage?.image = self.bookInformation?.thumbnail
        self.backgroundImage?.image = self.bookInformation?.thumbnail
        self.summaryTextArea?.text = self.bookInformation?.summary
    }
}