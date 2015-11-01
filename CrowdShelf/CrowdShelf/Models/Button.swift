//
//  Button.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class Button: Listable {
    enum ButtonStyle {
        case Normal, Danger, None
        
        var titleColor: UIColor {
            switch self {
            case .Danger:
                return ColorPalette.dangerColor
            case .None, .Normal:
                return ColorPalette.primaryTextColor
            }
        }
        
        var subtitleColor: UIColor {
            switch self {
            case .Danger:
                return ColorPalette.dangerColor
            case .None, .Normal:
                return ColorPalette.lightGrayColor()
            }
        }
        
        var imageTintColor: UIColor {
            switch self {
            case .Danger:
                return ColorPalette.dangerColor
            case .Normal:
                return UIView.appearance().tintColor
            case .None:
                return ColorPalette.primaryTextColor
            }
        }
        
        var imageBorderColor: UIColor {
            switch self {
            case .Danger, .Normal:
                return UIColor.clearColor()
            case .None:
                return ColorPalette.dividerColor
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
