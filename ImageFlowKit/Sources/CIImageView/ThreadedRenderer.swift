import CoreImage
import Helpers
import MetalKit
import OSLog
import Synchronization
import XKit
import os

final class ThreadedRenderer {

    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPassDescriptor: MTLRenderPassDescriptor
    private let context: CIContext

    var thread: Thread!
    var sema: DispatchSemaphore
    let renderData: Mutex<RenderData?> = .init(nil)
    var drawable: (any CAMetalDrawable)? = nil

    let label = "ThreadedRenderer"

    init(_ device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.commandQueue.label = self.label
        self.renderPassDescriptor = .init()
        self.context = CIContext(
            mtlDevice: device,
            options: [
                .cacheIntermediates: false,
                .highQualityDownsample: true,
                .allowLowPower: false,
            ]
        )
        self.renderPassDescriptor.colorAttachments[0].loadAction = .clear
        self.renderPassDescriptor.colorAttachments[0].storeAction = .store
        self.renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        self.sema = .init(value: 0)
        self.thread = Thread(target: self, selector: #selector(Self.run), object: nil)
        self.thread.name = "ThreadedRenderer"
        self.thread.start()
    }

    @objc func run() {
        while true {
            self.sema.wait()
            if let rd = self.renderData.withLock({ $0 }) {
                self.doRender(rd)
            }
        }
    }

    public func render(_ renderData: RenderData, _ drawable: (any CAMetalDrawable)?) {
        self.renderData.withLock({ rd in
            rd = renderData
        })
        self.drawable = drawable
        self.sema.signal()
    }

    private func doRender(_ rd: RenderData) {
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

        guard let commandBuffer = self.commandQueue.makeCommandBuffer(),
            let drawable = self.drawable
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
            drawable.present()

            _ = try task.waitUntilCompleted()
        } catch {
            print("failed to render image: \(error)")
        }
    }
}
