import UniformTypeIdentifiers

extension UTType {
    static let cubeLut: UTType = {
        UTType(importedAs: "com.apple.videoapps.cube")
    }()
}

extension UTType {
    var isImage: Bool {
        self.conforms(to: .image)
    }

    var isCubeLut: Bool {
        self.conforms(to: .cubeLut)
    }

    var assetKind: AssetKind? {
        if self.isImage {
            .image
        } else if self.isCubeLut {
            .lut
        } else {
            nil
        }
    }
}
