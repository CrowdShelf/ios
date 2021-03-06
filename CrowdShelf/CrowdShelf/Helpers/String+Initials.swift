//
//  String+Initials.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation

extension String {
    var initials: String? {
        if self.characters.isEmpty {
            return nil
        }
        
        var initials = ""
        for word in self.componentsSeparatedByString(" ") {
            if let firstCharacter = word.characters.first {
                initials.append(firstCharacter)
            }
        }
        
        return initials.uppercaseString
    }
}