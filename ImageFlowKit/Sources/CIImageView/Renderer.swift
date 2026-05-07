import CoreImage
import Helpers
import MetalKit
import OSLog
import Synchronization
import XKit
import os

@MainActor
class Renderer {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPassDescriptor: MTLRenderPassDescriptor
    private let context: CIContext

    let label: String = "CIImageView Renderer"

    init(_ device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.commandQueue.label = self.label
        self.renderPassDescriptor = .init()
        self.context = CIContext(
            mtlDevice: device,
            options: [.cacheIntermediates: true, .highQualityDownsample: true, .allowLowPower: false]
        )
        self.renderPassDescriptor.colorAttachments[0].loadAction = .clear
        self.renderPassDescriptor.colorAttachments[0].storeAction = .store
        self.renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    func render(_ rd: RenderData, _ drawable: (() -> (any CAMetalDrawable)?)) {
        guard let image = rd.image else { return }
        guard rd.drawableSize.width > 0, rd.drawableSize.height > 0 else { return }

        let id = sp.makeSignpostID()
        let state = sp.beginInterval("Renderer::render", id: id)
        defer { sp.endInterval("Renderer::render", state) }

        #if os(iOS)
        let available = os_proc_available_memory()

        if available < 50 * 1024 * 1024 {
            print("[CIImageXView] low memory, skipping render!")
            return
        }
        #endif

        // self.updatePlacement()

        guard let commandBuffer = self.commandQueue.makeCommandBuffer(),
            let drawable = drawable()
        else { return }

        commandBuffer.label = self.label

        self.renderPassDescriptor.colorAttachments[0].texture = drawable.texture

        if let enc = commandBuffer.makeRenderCommandEncoder(descriptor: self.renderPassDescriptor) {
            enc.label = self.label
            enc.endEncoding()
        }

        let sampledImage =
            if rd.isZoomedIn {
                image.samplingNearest()
            } else {
                image.samplingLinear()
            }

        let finalImage = sampledImage.transformed(by: .init(scaleX: rd.imageScale.width, y: rd.imageScale.height))

        let dest = CIRenderDestination(
            width: Int(rd.drawableSize.width),
            height: Int(rd.drawableSize.height),
            pixelFormat: rd.pixelFormat,
            commandBuffer: commandBuffer,
            mtlTextureProvider: { drawable.texture }
        )

        do {
            let task = try self.context.startTask(
                toRender: finalImage,
                from: finalImage.extent,
                to: dest,
                at: rd.offset
            )

            commandBuffer.commit()
            // commandBuffer.waitUntilScheduled()
            // commandBuffer.scheduled()
            drawable.present()

            _ = try task.waitUntilCompleted()
        } catch {
            print("failed to render image: \(error)")
        }
    }
}

struct RenderData: Sendable {
    var image: CIImage?
    var drawableSize: CGSize
    var pixelFormat: MTLPixelFormat
    var isZoomedIn: Bool
    var imageScale: CGSize
    var offset: CGPoint
}

extension RenderData: CustomStringConvertible {
    // swift-format-ignore
    var description: String {
        "RenderData:\n" +
        "  image extent: \(image?.extent ?? .zero)\n" +
        "  drawableSize: \(drawableSize)\n" +
        "  pixelFormat: \(pixelFormat)\n" +
        "  isZoomedIn: \(isZoomedIn)\n" +
        "  imageScale: \(imageScale)\n" +
        "  offset: \(offset)\n"
    }
}
