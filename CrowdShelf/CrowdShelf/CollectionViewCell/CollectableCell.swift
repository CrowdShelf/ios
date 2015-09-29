//
//  CSBookCollectionViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CollectableCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    
    
    var collectable : Collectable? {
        didSet {
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView?.layer.borderWidth = 1
        self.imageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func updateView() {
        self.imageView?.image = self.collectable?.image
        self.titleLabel?.text = self.collectable?.title
    }
    
}
