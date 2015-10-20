//
//  ListTableViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 14/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class ListTableViewCell: UITableViewCell {
    var listable: Listable? {
        didSet {
            self.updateView()
        }
    }
    
    @IBOutlet weak var iconImageView: AlternativeInfoImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    @IBOutlet var titleLabelAlignCenterYConstraint: NSLayoutConstraint?
    @IBOutlet var titleLabelTopSpaceConstrant: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView!.viewStyle = .Round
    }
    
    
    
    func updateView() {
        titleLabel?.text = listable?.title
        subtitleLabel?.text = (listable?.subtitle) ?? ""
        iconImageView?.alternativeInfo = listable?.title.initials
        iconImageView?.image = listable?.image ?? nil
        
        titleLabelAlignCenterYConstraint?.active = listable?.subtitle == nil
        titleLabelTopSpaceConstrant?.active = listable?.subtitle != nil
        
        self.layoutIfNeeded()
    }
}