//
//  AlternativeInfoImageView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

enum ViewStyle {
    case Round, Square
    
    func styleView(view: UIView) {
        let layer = view.layer
        switch self {
        case .Round:
            layer.cornerRadius = view.frame.height/2
            layer.masksToBounds = true
        case .Square:
            layer.cornerRadius = 0
        }
    }
}

class AlternativeInfoImageView: UIImageView {
    
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var showBorder: Bool = false {
        didSet {
            layer.borderWidth = showBorder ? 1 : 0
        }
    }
    
    @IBInspectable var alternativeInfoLabelFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 30)! {
        didSet {
            alternativeInfoLabel?.font = alternativeInfoLabelFont
        }
    }
    
    var viewStyle: ViewStyle = .Square {
        didSet {
            viewStyle.styleView(self)
        }
    }
    
    var alternativeInfo: String? {
        didSet {
            self.alternativeInfoLabel?.text = alternativeInfo
        }
    }
    
    override var image: UIImage? {
        set {
            super.image = newValue
            self.alternativeInfoLabel?.hidden = newValue != nil
            self.backgroundColor = newValue != nil ? UIColor.clearColor() : UIColor(white: 0.97, alpha: 1)
        }
        get {
            return super.image
        }
    }
    
    weak var alternativeInfoLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let infoLabel = initiatedLabel()
        
        self.addSubview(infoLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[infoLabel]-|", options: .AlignAllCenterY, metrics: nil, views: ["infoLabel": infoLabel]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[infoLabel]|", options: .AlignAllBaseline, metrics: nil, views: ["infoLabel": infoLabel]))
        
        self.alternativeInfoLabel = infoLabel
    }
    
    func initiatedLabel() -> UILabel {
        let infoLabel = UILabel()
        infoLabel.textAlignment = .Center
        infoLabel.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        infoLabel.textColor = UIColor.grayColor()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.minimumScaleFactor = 0.4
        infoLabel.baselineAdjustment = .AlignCenters
        
        return infoLabel
    }
}
