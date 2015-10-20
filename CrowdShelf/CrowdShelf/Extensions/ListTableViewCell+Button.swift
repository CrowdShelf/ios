//
//  ListTableViewCell+Button.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 20/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


extension ListTableViewCell {
    
    func configureForButtonStyle(buttonStyle: ListViewController.Button.ButtonStyle) {
        self.iconImageView?.borderColor = buttonStyle.imageBorderColor
        self.titleLabel?.textColor = buttonStyle.titleColor
        self.subtitleLabel?.textColor = buttonStyle.subtitleColor
        self.iconImageView?.tintColor = buttonStyle.titleColor
    }
    
}