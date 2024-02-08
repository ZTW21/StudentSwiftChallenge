//
//  File.swift
//
//
//  Created by Zack Wilson on 2/7/24.
//

struct Color {
    let r: UInt8
    let g: UInt8
    let b: UInt8
}

struct ColorBox {
    var colors: [Color]
    let count: Int
    
    init(colors: [Color]) {
        self.colors = colors
        self.count = colors.count
    }
    
    // Function to split the box, finding the median, and sorting.
    // This will depend on the implementation details of your median cut algorithm.
    func split() -> (ColorBox, ColorBox) {
        // Exclude pure black and pure white colors
        let filteredColors = colors.filter { color in
            !(color.r == 0 && color.g == 0 && color.b == 0) && !(color.r == 255 && color.g == 255 && color.b == 255)
        }
        
        // Calculate color ranges
        let rRange = (filteredColors.max(by: { $0.r < $1.r })?.r ?? 0) - (filteredColors.min(by: { $0.r < $1.r })?.r ?? 0)
        let gRange = (filteredColors.max(by: { $0.g < $1.g })?.g ?? 0) - (filteredColors.min(by: { $0.g < $1.g })?.g ?? 0)
        let bRange = (filteredColors.max(by: { $0.b < $1.b })?.b ?? 0) - (filteredColors.min(by: { $0.b < $1.b })?.b ?? 0)
        
        
        // Determine the dimension to split along
        let maxRangeDimension = max(rRange, gRange, bRange)
        let sortDimension: (Color, Color) -> Bool
        
        if maxRangeDimension == rRange {
            sortDimension = { $0.r < $1.r }
        } else if maxRangeDimension == gRange {
            sortDimension = { $0.g < $1.g }
        } else {
            sortDimension = { $0.b < $1.b }
        }
        
        // Sort colors by the chosen dimension
        let sortedColors = filteredColors.sorted(by: sortDimension)
        
        // Find the median index to split at, considering only non-extreme colors
        let medianIndex = sortedColors.count / 2
        
        // Split the sorted colors into two halves
        let firstHalfColors = Array(sortedColors[..<medianIndex])
        let secondHalfColors = Array(sortedColors[medianIndex...])
        
        // Create two new color boxes from the split
        let box1 = ColorBox(colors: firstHalfColors)
        let box2 = ColorBox(colors: secondHalfColors)
        
        return (box1, box2)
    }
    
    func averageColor() -> Color {
        let sum = colors.reduce((0, 0, 0)) { acc, color in
            (Int(color.r) + acc.0, Int(color.g) + acc.1, Int(color.b) + acc.2)
        }
        let count = colors.count
        return Color(r: UInt8(sum.0 / count), g: UInt8(sum.1 / count), b: UInt8(sum.2 / count))
    }
}
