import Foundation
import Logging
import SharedModels
import UniformTypeIdentifiers

public struct AssetKindSet: Sendable, OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int

    public static func assetKind(_ kind: AssetKind) -> Self {
        switch kind {
        case .image: [.image]
        case .lut: [.lut]
        }
    }

    public static let image = AssetKindSet(rawValue: 1 << 0)
    public static let lut = AssetKindSet(rawValue: 1 << 1)
    public static let all: AssetKindSet = [.image, .lut]

    public var kinds: Set<AssetKind> {
        var s = Set<AssetKind>()

        if self.contains(.image) {
            s.insert(.image)
        }

        if self.contains(.lut) {
            s.insert(.lut)
        }

        return s
    }

    public var types: [UTType] {
        var result = [UTType]()

        if self.contains(.image) {
            result.append(.image)
        }

        if self.contains(.lut) {
            result.append(.cubeLut)
        }

        return result
    }

    public func contains(_ assetKind: AssetKind) -> Bool {
        self.contains(.assetKind(assetKind))
    }
}
