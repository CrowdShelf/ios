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
    
    
    var book : CSBook? {
        didSet {
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.coverImageView?.layer.borderWidth = 1
        self.coverImageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func updateView() {
        self.coverImageView?.image = self.book?.details?.thumbnail
        self.titleLabel?.text = self.book?.details?.title
    }
    
}
