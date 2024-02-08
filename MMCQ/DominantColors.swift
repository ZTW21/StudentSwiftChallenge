//
//  File.swift
//  
//
//  Created by Zack Wilson on 2/7/24.
//

import UIKit

func dominantColors(from colorBoxes: [ColorBox]) -> [UIColor] {
    return colorBoxes.map { box in
        let sum = box.colors.reduce((0, 0, 0)) { acc, color in
            (Int(color.r) + acc.0, Int(color.g) + acc.1, Int(color.b) + acc.2)
        }
        let count = box.colors.count
        return UIColor(red: CGFloat(sum.0 / count) / 255.0,
                       green: CGFloat(sum.1 / count) / 255.0,
                       blue: CGFloat(sum.2 / count) / 255.0,
                       alpha: 1.0)
    }
}
