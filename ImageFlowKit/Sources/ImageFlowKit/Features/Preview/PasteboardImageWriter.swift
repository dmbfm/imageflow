#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

@MainActor
class PasteboarImageWriter {
    var copyTask: Task<(), any Error>? = nil

    func copy(_ image: CIImage) {
        self.copyTask?.cancel()
        self.copyTask = Task {
            try await self.doCopy(image)
            self.copyTask = nil
        }
    }

    #if os(iOS)
    @concurrent
    func doCopy(_ image: CIImage) async throws {
        let uiImage = UIImage(ciImage: image)
        do {
            try Task.checkCancellation()
            UIPasteboard.general.image = uiImage
        }
    }
    #endif

    #if os(macOS)
    @concurrent
    func doCopy(_ image: CIImage) async throws {
        let context = CIContext()
        if let cgImage = context.createCGImage(image, from: image.extent) {
            do {
                try Task.checkCancellation()
                let nsImage = NSImage(cgImage: cgImage, size: .init(width: cgImage.width, height: cgImage.height))
                let pb = NSPasteboard.general
                try Task.checkCancellation()
                pb.clearContents()
                pb.writeObjects([nsImage])
            }
        }
    }
    #endif
}
