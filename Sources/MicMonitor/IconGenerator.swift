import AppKit
import CoreGraphics

struct IconGenerator {

    static let iconSize = NSSize(width: 20, height: 20)

    static func icon(for level: VolumeLevel) -> NSImage {
        let image = NSImage(size: iconSize, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            self.drawWaveform(in: rect, level: level, context: ctx)
            return true
        }
        image.isTemplate = false
        return image
    }

    static func disabledIcon() -> NSImage {
        let image = NSImage(size: iconSize, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.setFillColor(NSColor.gray.withAlphaComponent(0.4).cgColor)
            ctx.fillEllipse(in: CGRect(x: rect.midX - 4, y: rect.midY - 6, width: 8, height: 6))
            ctx.fill(CGRect(x: rect.midX - 2, y: rect.midY - 4, width: 4, height: 10))
            ctx.setLineWidth(1.5)
            ctx.setStrokeColor(NSColor.gray.withAlphaComponent(0.4).cgColor)
            ctx.move(to: CGPoint(x: rect.midX, y: rect.midY + 6))
            ctx.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 10))
            ctx.strokePath()
            return true
        }
        image.isTemplate = false
        return image
    }

    private static func drawWaveform(in rect: CGRect, level: VolumeLevel, context ctx: CGContext) {
        let barCount = 4
        let barWidth: CGFloat = 2.5
        let spacing: CGFloat = 2.0
        let totalWidth = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * spacing
        let startX = rect.midX - totalWidth / 2

        let maxHeight: CGFloat
        switch level {
        case .quiet:    maxHeight = 6
        case .moderate: maxHeight = 11
        case .loud:     maxHeight = 16
        }

        ctx.setFillColor(level.color.cgColor)

        for i in 0..<barCount {
            let barHeight: CGFloat
            switch level {
            case .quiet:
                barHeight = maxHeight * [0.4, 0.6, 0.8, 0.5][i]
            case .moderate:
                barHeight = maxHeight * [0.5, 0.7, 1.0, 0.6][i]
            case .loud:
                barHeight = maxHeight * [0.6, 0.8, 1.0, 0.7][i]
            }

            let x = startX + CGFloat(i) * (barWidth + spacing)
            let y = rect.midY - barHeight / 2
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = CGPath(roundedRect: barRect, cornerWidth: 1, cornerHeight: 1, transform: nil)
            ctx.addPath(path)
            ctx.fillPath()
        }
    }
}
