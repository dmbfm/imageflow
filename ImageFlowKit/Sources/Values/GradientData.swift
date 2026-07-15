import Helpers

public struct GradientData: Sendable, Hashable, Codable, With {

    public var stops: [Stop] = []
    public var noiseAmount: Double = 0.0
    public var interpolation: InterpolationType = .linear

    public enum InterpolationType: Int, Sendable, Equatable, Codable {
        case linear
        case step
    }

    public struct Stop: Sendable, Hashable, Codable, With {
        public var position: Double
        public var color: Color4

        public init(position: Double, color: Color4) {
            self.position = position
            self.color = color
        }
    }

    public init(_ stops: [Stop], noiseAmount: Double = 0.0, interpolation: InterpolationType = .linear) {
        self.stops = stops
        self.interpolation = interpolation
        self.noiseAmount = 0.0
    }

    public static let `default`: Self = .init([
        .init(position: 0.0, color: .black),
        .init(position: 1.0, color: .white),
    ])
}
