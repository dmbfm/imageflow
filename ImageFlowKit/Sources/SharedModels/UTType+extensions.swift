import UniformTypeIdentifiers

extension UTType {
    public static let cubeLut: UTType = {
        UTType(importedAs: "com.apple.videoapps.cube")
    }()
}

extension UTType {
    public var isImage: Bool {
        self.conforms(to: .image)
    }

    public var isCubeLut: Bool {
        self.conforms(to: .cubeLut)
    }

    public var assetKind: AssetKind? {
        if self.isImage {
            .image
        } else if self.isCubeLut {
            .lut
        } else {
            nil
        }
    }
}
