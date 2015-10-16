//
//  AVMetadataMachineReadableCodeObject+Frame.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 14/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import AVFoundation

extension AVMetadataMachineReadableCodeObject {
    
    var frame: CGRect {
        print(self.corners)
        if let cornersArray = self.corners as? [[String: String]] {
            let dataArray: [[Float]] = cornersArray.map {
                $0.values.map { ($0 as NSString).floatValue }
            }
            
            return CGRectMake(
                CGFloat(dataArray.first![0]),
                CGFloat(dataArray.first![1]),
                CGFloat(dataArray.last![0] - dataArray.first![0]),
                CGFloat(dataArray[1][1] - dataArray.first![1])
            )
        }
        
        return CGRectZero
    }
}