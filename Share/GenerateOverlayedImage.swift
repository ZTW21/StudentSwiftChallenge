//
//  File.swift
//  
//
//  Created by Zack Wilson on 2/8/24.
//

import UIKit

func generateOverlayedImage(with paletteColors: [UIColor], for originalImage: UIImage, completion: @escaping (UIImage?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let imageSize = originalImage.size
        let paletteColumns = 3
        let squareSize: CGFloat = 175  // Size of each color square
        let spacing: CGFloat = 10     // Spacing between squares
        let cornerRadius: CGFloat = 10 // Corner radius of each square
        let padding: CGFloat = 75     // Padding from the edges of the image

        let paletteWidth = CGFloat(paletteColumns) * squareSize + CGFloat(paletteColumns - 1) * spacing
        let paletteHeight = paletteWidth

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        // Draw the original image
        originalImage.draw(in: CGRect(origin: .zero, size: imageSize))

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState() // Save the current graphics state

        // Apply drop shadow
        context?.setShadow(offset: CGSize(width: 0, height: 2), blur: 6, color: UIColor.black.cgColor)

        // Starting position for the palette (bottom right corner with padding)
        let startX = imageSize.width - paletteWidth - padding
        let startY = imageSize.height - paletteHeight - padding

        // Draw each color square in the palette
        for (index, color) in paletteColors.prefix(9).enumerated() { // Limit to 9 colors for a 3x3 grid
            let row = index / paletteColumns
            let column = index % paletteColumns
            let x = startX + CGFloat(column) * (squareSize + spacing)
            let y = startY + CGFloat(row) * (squareSize + spacing)
            let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)

            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            color.setFill()
            path.fill()
        }

        context?.restoreGState() // Restore the graphics state

        let overlayedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        DispatchQueue.main.async {
            completion(overlayedImage)
        }
    }
}

