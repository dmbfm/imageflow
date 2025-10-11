import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

extension CGImage {
    public enum WriteError: Error {
        case failedToCreateDestination
        case failedToWriteToDestination
    }

    public func write(to url: URL, type: UTType) throws {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, type.identifier as CFString, 1, nil)
        else {
            throw WriteError.failedToCreateDestination
        }

        CGImageDestinationAddImage(destination, self, nil)

        if !CGImageDestinationFinalize(destination) {
            throw WriteError.failedToWriteToDestination
        }
    }
}
