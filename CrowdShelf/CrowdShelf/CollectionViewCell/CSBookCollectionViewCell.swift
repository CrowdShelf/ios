//
//  CSBookCollectionViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CSBookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var coverImageView: UIImageView?
    @IBOutlet weak var numberOfCopiesLabel: UILabel?
    
    
    var book : CSBook? {
        didSet {
            self.updateView()
            
            
            CSDataHandler.detailsForBook(self.book!.isbn, withCompletionHandler: { (details) -> Void in
                self.book?.details = details
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateView()
                })
            })
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.coverImageView?.layer.borderWidth = 1
        self.coverImageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func updateView() {
        self.coverImageView?.image = self.book?.details?.thumbnailImage
        self.titleLabel?.text = self.book?.details?.title
        
        if self.book != nil {
            self.numberOfCopiesLabel?.text = "\(self.book!.numberOfCopies)"
        }
    }
    
}
