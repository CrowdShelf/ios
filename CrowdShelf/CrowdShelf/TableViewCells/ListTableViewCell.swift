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
    
    
    func updateView() {
        textLabel?.text = listable?.title
        detailTextLabel?.text = listable?.subtitle
        imageView?.image = listable?.image ?? UIImage()
    }
}