import SwiftUI

struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var showingActionSheet = false // To track action sheet presentation
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary // To specify source type
    @State private var paletteColors: [SwiftUI.Color] = Array(repeating: SwiftUI.Color.gray, count: 9) // Placeholder colors
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var opacity: Double = 0
    
    @State private var lastCopiedColor: SwiftUI.Color = SwiftUI.Color.gray
    
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    self.showingActionSheet = true // Show action sheet when button is tapped
                }) {
                    Text("Select Image")
                        .foregroundColor(.white)
                        .padding()
                        .background(SwiftUI.Color.blue)
                        .clipShape(Capsule())
                }
                .padding()
                .actionSheet(isPresented: $showingActionSheet) { // Action sheet
                    ActionSheet(title: Text("Select Image"), message: Text("Choose the image source"), buttons: [
                        .default(Text("Camera")) {
                            self.sourceType = .camera
                            self.showingImagePicker = true
                        },
                        .default(Text("Photo Library")) {
                            self.sourceType = .photoLibrary
                            self.showingImagePicker = true
                        },
                        .cancel()
                    ])
                }
                
                ZStack {
                    Rectangle()
                        .foregroundStyle(SwiftUI.Color.clear)
                        .aspectRatio(1, contentMode: .fit)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .padding()
                }
                .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) { // Increased spacing between squares
                    ForEach(0..<9, id: \.self) { index in
                        Rectangle()
                            .foregroundColor(paletteColors[index])
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(10) // Rounded corners
                            .shadow(radius: 5)
                            .onTapGesture {
                                let copiedColor = paletteColors[index]
                                copyColorToClipboard(color: paletteColors[index])
                                lastCopiedColor = copiedColor
                                showToast(message: "Color copied to clipboard")
                            }
                        // Check if the current square is one of the corners
                            .overlay(
                                index == 0 || index == 2 || index == 6 || index == 8 ?
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(SwiftUI.Color.yellow)
                                : nil
                            )
                    }
                }
                .padding() // Padding around the entire grid
            }
            if showingToast {
                HStack(spacing: 10) {
                    Text(toastMessage)
                    Rectangle()
                        .fill(lastCopiedColor) // Use the last copied color for the square
                        .frame(width: 20, height: 20) // Small square size
                        .cornerRadius(3) // Optional: Rounds the corners of the square
                }
                .padding()
                .background(SwiftUI.Color.black)
                .foregroundColor(SwiftUI.Color.white)
                .cornerRadius(8)
                .opacity(opacity)
                .onAppear {
                    self.opacity = 0
                    
                    withAnimation(.easeIn(duration: 0.25)) {
                        self.opacity = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.opacity = 0
                        }
                    }
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.85)
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(selectedImage: self.$inputImage, sourceType: self.sourceType) // Pass the source type to ImagePicker
        }
    }
    
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let compressedImage = resizeImage(image: inputImage, targetHeight: 200)
        
        image = Image(uiImage: inputImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Use the median cut algorithm to extract dominant colors from the image
            let dominantColors = self.dominantColorsFromImage(image: compressedImage, colorCount: 4)
            print(dominantColors)
            
            DispatchQueue.main.async {
                if dominantColors.count >= 4 {
                    self.paletteColors[0] = SwiftUI.Color(dominantColors[0]) // Top left corner
                    self.paletteColors[2] = SwiftUI.Color(dominantColors[1]) // Top right corner
                    self.paletteColors[6] = SwiftUI.Color(dominantColors[2]) // Bottom left corner
                    self.paletteColors[8] = SwiftUI.Color(dominantColors[3]) // Bottom right corner
                    
                    // Blend colors for the remaining palette slots
                    self.paletteColors[1] = SwiftUI.Color(self.blendColors(dominantColors[0], dominantColors[1])) // Top edge
                    self.paletteColors[3] = SwiftUI.Color(self.blendColors(dominantColors[0], dominantColors[2])) // Left edge
                    self.paletteColors[5] = SwiftUI.Color(self.blendColors(dominantColors[1], dominantColors[3])) // Right edge
                    self.paletteColors[7] = SwiftUI.Color(self.blendColors(dominantColors[2], dominantColors[3])) // Bottom edge
                    
                    // Blend center color from the edge colors
                    self.paletteColors[4] = SwiftUI.Color(self.blendColors(self.blendColors(dominantColors[0], dominantColors[1]), self.blendColors(dominantColors[2], dominantColors[3])))
                    
                    // Print the colors in the paletteColors array
                    for (index, color) in self.paletteColors.enumerated() {
                        print("Color \(index):", color.description)
                    }
                } else {
                    print("Not enough dominant colors were extracted.")
                }
            }
        }
    }
    
    func dominantColorsFromImage(image: UIImage, colorCount: Int) -> [UIColor] {
        guard let inputPixels = image.pixelData() else { return [] }
        var colors = [Color]()
        
        for i in 0..<inputPixels.count where i % 4 == 0 {
            let r = inputPixels[i]
            let g = inputPixels[i + 1]
            let b = inputPixels[i + 2]
            colors.append(Color(r: r, g: g, b: b))
        }
        
        var colorBoxes = [ColorBox(colors: colors)]
        
        while colorBoxes.count < colorCount {
            colorBoxes.sort { $0.count > $1.count }
            guard let largestBox = colorBoxes.first else { break }
            let (box1, box2) = largestBox.split()
            colorBoxes.removeFirst()
            colorBoxes.append(contentsOf: [box1, box2])
        }
        
        let dominantColors = colorBoxes.map { box -> UIColor in
            let averageColor = box.averageColor()
            return UIColor(red: CGFloat(averageColor.r) / 255.0,
                           green: CGFloat(averageColor.g) / 255.0,
                           blue: CGFloat(averageColor.b) / 255.0,
                           alpha: 1.0)
        }
        
        return dominantColors
    }
    
    func blendColors(_ color1: UIColor, _ color2: UIColor) -> UIColor {
        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: (r1 + r2) / 2, green: (g1 + g2) / 2, blue: (b1 + b2) / 2, alpha: (a1 + a2) / 2)
    }
    
    func copyColorToClipboard(color: SwiftUI.Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let hexString = String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
        UIPasteboard.general.string = hexString
    }
    
    func showToast(message: String) {
        // Reset the toast state to allow it to be triggered again
        withAnimation {
            showingToast = false
            opacity = 0
        }
        
        // Update the message and make the toast visible
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                showingToast = true
                opacity = 1
            }
            
            // Hide the toast after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                }
            }
        }
    }
    
    
    func resizeImage(image: UIImage, targetHeight: CGFloat) -> UIImage {
        let size = image.size
        let heightRatio = targetHeight / size.height
        let newWidth = size.width * heightRatio
        let newSize = CGSize(width: newWidth, height: targetHeight)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
