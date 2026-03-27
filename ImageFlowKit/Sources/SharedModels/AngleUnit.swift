public enum AngleUnit: Hashable, Sendable, Codable {
    case degrees
    case radians

    public func radians(_ value: Double) -> Double {
        switch self {
        case .radians: value
        case .degrees: value.radians
        }
    }

    public func degrees(_ value: Double) -> Double {
        switch self {
        case .radians: value.degrees
        case .degrees: value
        }
    }

    public var shortLabel: String {
        switch self {
        case .radians: " rad"
        case .degrees: " °"
        }
    }
}

extension Double {
    public func fromDegrees(to unit: AngleUnit) -> Double {
        unit.radians(self)
    }

    public func fromRadians(to unit: AngleUnit) -> Double {
        unit.degrees(self)
    }
}
