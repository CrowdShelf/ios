//
//  CSBookCollectionViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

enum CollectableCellImageViewStyle: Int {
    case Square
    case Round
}

class CollectableCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var initialLabel: UILabel?
    
    var imageViewStyle: CollectableCellImageViewStyle = .Square {
        didSet {
            configureImageView()
        }
    }
    
    var collectable : Collectable? {
        didSet {
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateView() {
        self.imageView?.image = self.collectable?.image
        self.titleLabel?.text = self.collectable?.title
                
        if self.collectable?.title.characters.first != nil {
            self.initialLabel?.text = String(self.collectable!.title.characters.first!).uppercaseString
        } else {
            self.initialLabel?.text = ""
        }
        
        self.initialLabel?.hidden = self.collectable?.image != nil
    }
    
    func configureImageView() {
        let layer = self.imageView?.layer
        
        layer?.borderWidth = 1
        layer?.borderColor = UIColor.lightGrayColor().CGColor
        
        switch self.imageViewStyle {
        case .Round:
            layer?.cornerRadius = self.imageView!.frame.height/2
            layer?.masksToBounds = true
        case .Square:
            layer?.masksToBounds = false
            layer?.cornerRadius = 0
        }
    }
    
}
