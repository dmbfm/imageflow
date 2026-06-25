import Foundation

extension FloatingPointFormatStyle<Double> {
    public static let `default`: Self = .number.precision(.fractionLength(2...12))
    public static let int: Self = .number.rounded().precision(.fractionLength(0))
}
