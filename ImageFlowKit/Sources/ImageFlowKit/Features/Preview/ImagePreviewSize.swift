import Foundation

public enum ImagePreviewSize: Equatable {
    case large
    case medium
    case small

    var size: CGFloat {
        switch self {
        case .large: 400
        case .medium: 200
        case .small: 50
        }
    }

    func iter() -> ImagePreviewSizeIter {
        .init(self)
    }
}

public struct ImagePreviewSizeIter: Equatable {

    public private(set) var current: ImagePreviewSize
    private var prev: ImagePreviewSize?

    init(_ size: ImagePreviewSize = .medium) {
        self.current = size
    }

    mutating func step() {
        let tmp = self.current
        self.current =
            switch self.current {
            case .small: .medium
            case .large: .medium
            case .medium:
                if let prev = self.prev {
                    switch prev {
                    case .large: .small
                    case .medium: .large
                    case .small: .large
                    }
                } else {
                    .large
                }
            }
        self.prev = tmp
    }

    mutating func next() -> ImagePreviewSize {
        self.step()
        return self.current
    }
}
