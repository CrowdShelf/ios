//
//  ListViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 16/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class ListViewController: UIViewController {
    
    class Button: Listable {
        enum ButtonStyle {
            case Normal, Danger, None
            
            var titleColor: UIColor {
                switch self {
                case .Normal:
                    return UIView().tintColor
                case .Danger:
                    return UIColor.redColor()
                case .None:
                    return UIColor.blackColor()
                }
            }
            
            var subtitleColor: UIColor {
                switch self {
                case .Normal:
                    return UIView().tintColor
                case .Danger:
                    return UIColor.redColor()
                case .None:
                    return UIColor.lightGrayColor()
                }
            }
            
            var imageBorderColor: UIColor {
                switch self {
                case .Danger, .Normal:
                    return UIColor.clearColor()
                case .None:
                    return UIColor.lightGrayColor()
                }
            }
        }
        
        @objc var title: String
        @objc var subtitle: String?
        @objc var image: UIImage?
        var buttonStyle: ButtonStyle
        
        init(title: String, subtitle: String? = nil, image: UIImage? = nil, buttonStyle: ButtonStyle = .Normal) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.buttonStyle = buttonStyle
        }
    }
    
    @IBOutlet var tableView: UITableView?
    
    lazy var tableViewDataSource: TableViewArrayDataSource = {
        return TableViewArrayDataSource(cellReuseIdentifier: ListTableViewCell.cellReuseIdentifier) { (cell, item, indexPath) -> Void in
            
            let listCell = cell as? ListTableViewCell
            listCell?.listable = item as? Listable
            listCell?.configureForButtonStyle((item as? Button)?.buttonStyle ?? .None)
            listCell?.accessoryType = self.accessoryTypeForIndexPath(indexPath)
            
        }
    }()
    
    lazy var tableViewDelegate: TableViewSelectionDelegate = {
        return TableViewSelectionDelegate { (_, indexPath, selected) -> Void in }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.registerCellForClass(ListTableViewCell)
        
        tableView!.dataSource = tableViewDataSource
        tableView!.delegate = tableViewDelegate
        
        tableView!.reloadData()
    }
    
    func accessoryTypeForIndexPath(indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
        return .None
    }
}