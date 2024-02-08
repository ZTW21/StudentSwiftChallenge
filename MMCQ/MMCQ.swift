//
//  File.swift
//  
//
//  Created by Zack Wilson on 2/7/24.
//

import UIKit

func medianCut(image: UIImage, colorCount: Int) -> [ColorBox] {
    guard let pixels = image.pixelData() else { return [] }
    var colors = [Color]()

    for i in 0..<pixels.count where i % 4 == 0 {
        let r = pixels[i]
        let g = pixels[i + 1]
        let b = pixels[i + 2]
        colors.append(Color(r: r, g: g, b: b))
    }

    var colorBoxes = [ColorBox(colors: colors)]

    while colorBoxes.count < colorCount {
        colorBoxes.sort { $0.count > $1.count } // Sort boxes by color count
        guard let largestBox = colorBoxes.first else { break }
        let (box1, box2) = largestBox.split() // Split the largest box
        colorBoxes.removeFirst() // Remove the largest box
        colorBoxes.append(contentsOf: [box1, box2]) // Add the new boxes
    }

    return colorBoxes
}
