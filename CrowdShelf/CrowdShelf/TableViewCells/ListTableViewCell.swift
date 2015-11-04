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
    
    var showSubtitle: Bool = false {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet weak var iconImageView: AlternativeInfoImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    @IBOutlet var titleLabelAlignCenterYConstraint: NSLayoutConstraint?

    func updateView() {
        titleLabel?.text = listable?.title
        subtitleLabel?.text = (listable?.subtitle) ?? nil
        iconImageView?.alternativeInfo = listable?.title?.initials
        iconImageView?.image = listable?.image ?? nil
        
        subtitleLabel?.hidden = !showSubtitle
        titleLabelAlignCenterYConstraint?.constant = !showSubtitle || subtitleLabel?.text == nil ? 0 : -10
        
        self.layoutIfNeeded()
    }
}