import AppKit
import Foundation

public struct TextStyle: Sendable, Hashable, Codable {
    public var fontName: String
    public var fontSize: CGFloat
    public var foregroundColor: Color4
    public var backgroundColor: Color4
    public var strokeColor: Color4
    public var strokeWidth: CGFloat
    public var underline: Int
    public var underlineColor: Color4
    public var shadowRadius: CGFloat
    public var shadowColor: Color4
    public var shadowOffset: Vector2

    public init(
        fontName: String = "Helvetica",
        fontSize: CGFloat = 22,
        foregroundColor: Color4 = .black,
        backgroundColor: Color4 = .clear,
        strokeColor: Color4 = .black,
        strokeWidth: CGFloat = 0.0,
        underline: UnderlineStyle = .none,
        underlineColor: Color4 = .black,
        shadowRadius: CGFloat = 0.0,
        shadowColor: Color4 = .init(red: 0, green: 0, blue: 0, alpha: 0.2),
        shadowOffset: Vector2 = .zero
    ) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.underline = underline.rawValue
        self.underlineColor = underlineColor
        self.shadowRadius = shadowRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
    }

    public enum UnderlineStyle: Int, CaseIterable {
        case none
        case single
        case thick
        // case dot
        // case dash
        // case dashDot
        // case dashDotDot
        // case byWord

        public var displayName: String {
            switch self {
            case .none: "None"
            case .single: "Single"
            case .thick: "Thick"
            // case .dot: "Dot"
            // case .dash: "Dash"
            // case .dashDot: "Dash-Dot"
            // case .dashDotDot: "Dash-Dot-Dot"
            // case .byWord: "Word"
            }
        }

        public var nsNumber: NSNumber {
            switch self {
            case .none: NSNumber(value: 0)
            case .single: NSNumber(value: NSUnderlineStyle.single.rawValue)
            case .thick: NSNumber(value: NSUnderlineStyle.thick.rawValue)
            // case .dot: NSNumber(value: NSUnderlineStyle.patternDot.rawValue)
            // case .dash: NSNumber(value: NSUnderlineStyle.patternDash.rawValue)
            // case .dashDot: NSNumber(value: NSUnderlineStyle.patternDashDot.rawValue)
            // case .dashDotDot: NSNumber(value: NSUnderlineStyle.patternDashDotDot.rawValue)
            // case .byWord: NSNumber(value: NSUnderlineStyle.byWord.rawValue)
            }
        }
    }
}
