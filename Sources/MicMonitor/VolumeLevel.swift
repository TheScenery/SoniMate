import AppKit

enum VolumeLevel: Int, CaseIterable {
    case quiet = 0
    case moderate = 1
    case loud = 2

    static let quietThreshold: Float = 0.3
    static let moderateThreshold: Float = 0.7

    static func from(normalizedValue: Float) -> VolumeLevel {
        switch normalizedValue {
        case ..<quietThreshold:
            return .quiet
        case quietThreshold..<moderateThreshold:
            return .moderate
        default:
            return .loud
        }
    }

    var color: NSColor {
        switch self {
        case .quiet:   return NSColor(red: 0.13, green: 0.77, blue: 0.37, alpha: 1.0)
        case .moderate: return NSColor(red: 0.92, green: 0.70, blue: 0.07, alpha: 1.0)
        case .loud:    return NSColor(red: 0.94, green: 0.23, blue: 0.18, alpha: 1.0)
        }
    }

    var label: String {
        switch self {
        case .quiet:    return "quiet"
        case .moderate: return "moderate"
        case .loud:     return "loud"
        }
    }
}
