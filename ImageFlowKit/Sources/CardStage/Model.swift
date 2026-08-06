import Foundation
import Helpers

public enum CardStageAnchor: String, Sendable, Equatable, Identifiable, CaseIterable, Codable {
    public var id: Self { self }
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

public enum CardVisibility {
    case visible
    case hidden

    var hidden: Bool {
        switch self {
        case .hidden: true
        case .visible: false
        }
    }
}

public enum CardDockLocation: Sendable, Equatable, Codable {
    case top
    case bottom
}
