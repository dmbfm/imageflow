public enum NumberFormat: Int, CaseIterable {
    case system
    case commaDot
    case noneDot
    case dotComma
    case noneComma

    var label: String {
        switch self {
            case .system: "System"
            case .commaDot: "1,234,567.89"
            case .noneDot: "1 234 567.89"
            case .dotComma: "1.234.567,89"
            case .noneComma: "1 234 567,89"
        }
    }
}
