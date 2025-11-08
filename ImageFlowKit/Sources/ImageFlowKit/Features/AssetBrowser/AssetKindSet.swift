import Foundation
import Logging
import UniformTypeIdentifiers

struct AssetKindSet: OptionSet {
    let rawValue: Int

    static let image = AssetKindSet(rawValue: 1 << 0)
    static let lut = AssetKindSet(rawValue: 1 << 1)

    static let all: AssetKindSet = [.image, .lut]

    var kinds: Set<AssetKind> {
        var s = Set<AssetKind>()

        if self.contains(.image) {
            s.insert(.image)
        }

        if self.contains(.lut) {
            s.insert(.lut)
        }

        return s
    }

    var types: [UTType] {
        var result = [UTType]()

        if self.contains(.image) {
            result.append(.image)
        }

        if self.contains(.lut) {
            result.append(.cubeLut)
        }

        return result
    }
}
