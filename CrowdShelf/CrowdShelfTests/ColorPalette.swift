//
//  ColorPalette.swift
//  CrowdShelf
//
//  Created by Maren Parnas Gulnes on 30.10.15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class ColorPalette: UIColor{
    static let primaryColor         = UIColor(netHex:0x03A9F4)
    static let darkPrimaryColor     = UIColor(netHex:0x0288D1)
    static let lightPrimaryColor    = UIColor(netHex:0xB3E5FC)
    static let textColor            = UIColor(netHex:0xFFFFFF)
    static let secondTextColor      = UIColor(netHex:0x727272)
    static let dividerColor         = UIColor(netHex:0xB6B6B6)
    static let primaryTextColor     = UIColor(netHex:0x212121)
    static let dangerColor          = UIColor(netHex:0xC7262C)
    
    static let randomColors = [
        UIColor(netHex: 0xf16364),
        UIColor(netHex: 0xf58559),
        UIColor(netHex: 0xe4c62e),
        UIColor(netHex: 0x67bf74),
        UIColor(netHex: 0x59a2be),
        UIColor(netHex: 0x2093cd),
        UIColor(netHex: 0xad62a7)
    ]
    
    
    class func colorForString(string: String) -> UIColor {
        let hashValue = string.hashValue
        let index = abs( hashValue % self.randomColors.count )
        return randomColors[index]
    }
}