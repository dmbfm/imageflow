@preconcurrency import CoreImage
import ImageIO
import UniformTypeIdentifiers

public struct CGImageSource {

    var source: ImageIO.CGImageSource

    public init?(url: URL, options: Options = .init()) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, options.dict() as CFDictionary) else {
            return nil
        }

        self.source = source
    }

    public func createImage(at index: Int, options: Options = .init()) -> CGImage? {
        return CGImageSourceCreateImageAtIndex(self.source, index, options.dict() as CFDictionary)
    }

    public func createThumbnail(at index: Int, options: Options = .init()) -> CGImage? {
        CGImageSourceCreateThumbnailAtIndex(self.source, index, options.dict() as CFDictionary)
    }

    public struct Options {
        public var typeIdentifierHint: UTType?
        public var shouldAllowFloat: Bool?
        public var shouldCache: Bool?
        public var shouldCacheImmediately: Bool?
        public var createThumbnailFromImageIfAbsent: Bool?
        public var createThumbnailFromImageAlways: Bool?
        public var thumbnailMaxPixelSize: Int?
        public var createThumbnailWithTransform: Bool?
        public var subsampleFactor: Int?

        public init(
            typeIdentifierHint: UTType? = nil,
            shouldAllowFloat: Bool? = nil,
            shouldCache: Bool? = nil,
            shouldCacheImmediately: Bool? = nil,
            createThumbnailFromImageIfAbsent: Bool? = nil,
            createThumbnailFromImageAlways: Bool? = nil,
            thumbnailMaxPixelSize: Int? = nil,
            createThumbnailWithTransform: Bool? = nil,
            subsampleFactor: Int? = nil
        ) {
            self.typeIdentifierHint = typeIdentifierHint
            self.shouldAllowFloat = shouldAllowFloat
            self.shouldCache = shouldCache
            self.shouldCacheImmediately = shouldCacheImmediately
            self.createThumbnailFromImageIfAbsent = createThumbnailFromImageIfAbsent
            self.createThumbnailFromImageAlways = createThumbnailFromImageAlways
            self.thumbnailMaxPixelSize = thumbnailMaxPixelSize
            self.createThumbnailWithTransform = createThumbnailWithTransform
            self.subsampleFactor = subsampleFactor
        }

        func dict() -> [CFString: Any] {
            var dict: [CFString: Any] = [:]
            if let sourceTypeIdentifierHint = self.typeIdentifierHint {
                dict[kCGImageSourceTypeIdentifierHint] = sourceTypeIdentifierHint.identifier as CFString
            }
            if let sourceShouldAllowFloat = self.shouldAllowFloat {
                dict[kCGImageSourceShouldAllowFloat] = sourceShouldAllowFloat
            }
            if let sourceShouldCache = self.shouldCache {
                dict[kCGImageSourceShouldCache] = sourceShouldCache
            }
            if let sourceShouldCacheImmediately = self.shouldCacheImmediately {
                dict[kCGImageSourceShouldCacheImmediately] = sourceShouldCacheImmediately
            }
            if let sourceCreateThumbnailFromImageIfAbsent = self.createThumbnailFromImageIfAbsent {
                dict[kCGImageSourceCreateThumbnailFromImageIfAbsent] = sourceCreateThumbnailFromImageIfAbsent
            }
            if let sourceCreateThumbnailFromImageAlways = self.createThumbnailFromImageAlways {
                dict[kCGImageSourceCreateThumbnailFromImageAlways] = sourceCreateThumbnailFromImageAlways
            }
            if let sourceThumbnailMaxPixelSize = self.thumbnailMaxPixelSize {
                dict[kCGImageSourceThumbnailMaxPixelSize] = sourceThumbnailMaxPixelSize
            }
            if let sourceCreateThumbnailWithTransform = self.createThumbnailWithTransform {
                dict[kCGImageSourceCreateThumbnailWithTransform] = sourceCreateThumbnailWithTransform
            }
            if let sourceSubsampleFactor = self.subsampleFactor {
                dict[kCGImageSourceSubsampleFactor] = sourceSubsampleFactor
            }
            return dict
        }
    }
}
