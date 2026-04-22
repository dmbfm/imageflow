import UniformTypeIdentifiers

extension UTType {
    public static let imageFlowDocument: UTType = UTType(exportedAs: "com.dmbfm.imageFlowDocument")
    public static let imageFlowNode: UTType = UTType("com.dmbfm.imageflow-node")!
    public static let imageFlowCubeLut: UTType = UTType(importedAs: "com.apple.videoapps.cube")
    public static let imageFlowNodeKindDragItem = UTType(exportedAs: "com.dmbfm.imageflow.node-kind")
}

extension UTType {
    public var isImage: Bool {
        self.conforms(to: .image)
    }

    public var isCubeLut: Bool {
        self.conforms(to: .imageFlowCubeLut)
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
