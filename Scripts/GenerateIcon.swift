import AppKit
import CoreGraphics

func generateIcon(size: NSSize, scale: CGFloat) -> NSImage {
    let w = Int(size.width * scale)
    let h = Int(size.height * scale)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(
        data: nil,
        width: w,
        height: h,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
    )!
    ctx.scaleBy(x: scale, y: scale)

    // Background rounded rect
    let bgRect = CGRect(origin: .zero, size: size)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: 16, cornerHeight: 16, transform: nil)
    ctx.setFillColor(CGColor(gray: 0.1, alpha: 1.0))
    ctx.addPath(bgPath)
    ctx.fillPath()

    // Draw 4 waveform bars
    let barCount = 4
    let barWidth: CGFloat = size.width * 0.12
    let spacing: CGFloat = size.width * 0.06
    let totalWidth = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * spacing
    let startX = (size.width - totalWidth) / 2
    let centerY = size.height / 2

    // Three colors for the three levels
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0.13, 0.77, 0.37), // green
        (0.92, 0.70, 0.07), // yellow
        (0.94, 0.23, 0.18), // red
    ]

    let maxHeights: [CGFloat] = [size.height * 0.3, size.height * 0.5, size.height * 0.7]
    let factors: [[CGFloat]] = [
        [0.4, 0.6, 0.8, 0.5],
        [0.5, 0.7, 1.0, 0.6],
        [0.6, 0.8, 1.0, 0.7],
    ]

    // Draw bars with gradient from green to yellow to red
    for i in 0..<barCount {
        let x = startX + CGFloat(i) * (barWidth + spacing)

        // Interpolate color based on bar index
        let t = CGFloat(i) / CGFloat(barCount - 1)
        let ci = min(Int(t * 2), 2)
        let color: (CGFloat, CGFloat, CGFloat)
        if ci == 0 {
            color = colors[0]
        } else if ci >= 2 {
            color = colors[2]
        } else {
            let lt = (t - 0.5) * 2
            color = (
                colors[0].0 + (colors[1].0 - colors[0].0) * lt,
                colors[0].1 + (colors[1].1 - colors[0].1) * lt,
                colors[0].2 + (colors[1].2 - colors[0].2) * lt
            )
        }

        ctx.setFillColor(CGColor(red: color.0, green: color.1, blue: color.2, alpha: 1.0))

        let barHeight: CGFloat
        if i < 2 {
            barHeight = maxHeights[0] * factors[0][i]
        } else {
            barHeight = maxHeights[1] * factors[1][i]
        }

        let barRect = CGRect(
            x: x,
            y: centerY - barHeight / 2,
            width: barWidth,
            height: barHeight
        )
        let path = CGPath(roundedRect: barRect, cornerWidth: barWidth / 2, cornerHeight: barWidth / 2, transform: nil)
        ctx.addPath(path)
        ctx.fillPath()
    }

    let cgImage = ctx.makeImage()!
    return NSImage(cgImage: cgImage, size: size)
}

// Generate icons at required sizes
let sizes: [(CGFloat, String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

let iconsetPath = "/tmp/SoniMate.iconset"
try FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for (size, name) in sizes {
    let icon = generateIcon(size: NSSize(width: size, height: size), scale: 1)
    let rep = NSBitmapImageRep(data: icon.tiffRepresentation!)!
    let pngData = rep.representation(using: .png, properties: [:])!
    try pngData.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name).png"))
}

print("Icons generated at \(iconsetPath)")
