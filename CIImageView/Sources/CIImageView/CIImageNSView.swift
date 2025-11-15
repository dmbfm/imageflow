import AppKit
import MetalKit

public class CIImageNSView: MTKView {

    // MARK: - Public Variables

    public var image: CIImage? = nil {
        didSet {
            self.updateDrawableSize()
            // self.invalidateIntrinsicContentSize()
            self.needsDisplay = true
        }
    }

    public var resizeMode: ResizeMode = .none {
        didSet {
            self.needsDisplay = true
        }
    }

    public var alignment: Alignment = .center {
        didSet {
            self.needsDisplay = true
        }
    }

    public var onMouseOver: ((PixelInfo?) -> ())?

    // MARK: - Public Types

    public enum Alignment: Hashable, Sendable, CaseIterable {
        case center
        case topLeft
        case topRight
        case top
        case bottom
        case bottomLeft
        case bottomRight
        case left
        case right
    }

    public enum ResizeMode: Hashable, Sendable, CaseIterable {
        case none
        case stretch
        case fit
        case fill
    }

    public struct PixelInfo {
        public var x: Int
        public var y: Int
        public var color: PixelColor
    }

    public struct PixelColor {
        public var r: UInt8
        public var g: UInt8
        public var b: UInt8
        public var a: UInt8
    }

    // MARK: - Private Variables

    private var context: CIContext

    private var commandQueue: MTLCommandQueue

    private var lastDrawableTexture: (any MTLTexture)?

    private var lastDrawnRect: CGRect?

    private var trackingArea: NSTrackingArea?

    // MARK: - Private Computed Variables

    private var backingScaleFactor: CGFloat {
        self.window?.backingScaleFactor ?? 1.0
    }

    // MARK: - Initializers

    public override init(frame frameRect: CGRect, device: (any MTLDevice)? = nil) {
        let device = device ?? MTLCreateSystemDefaultDevice()!
        self.context = CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        self.commandQueue = device.makeCommandQueue()!

        super.init(frame: frameRect, device: device)

        self.framebufferOnly = false
        self.colorPixelFormat = .rgba8Unorm
        self.delegate = self
        self.autoResizeDrawable = false
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        self.layer?.magnificationFilter = .nearest
        self.layer?.isOpaque = false
        self.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    @available(*, unavailable)
    public required init(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: - Public Methods

    public func getPixelInfo(_ point: CGPoint) -> PixelInfo? {
        if let image = self.image, let texture = self.lastDrawableTexture ?? self.currentDrawable?.texture,
            let rect = self.lastDrawnRect
        {
            let scaleX = rect.width / image.extent.width
            let scaleY = rect.height / image.extent.height
            let x = point.x * self.backingScaleFactor
            let y = point.y * self.backingScaleFactor

            if !rect.contains(.init(x: CGFloat(x), y: CGFloat(y))) {
                return nil
            }

            var color = [UInt8](repeating: 0, count: 4)
            let region = MTLRegionMake2D(Int(x), texture.height - Int(y) - 1, 1, 1)
            texture.getBytes(&color, bytesPerRow: 4, from: region, mipmapLevel: 0)

            return .init(
                x: Int((CGFloat(x) - rect.origin.x) / scaleX),
                y: Int((CGFloat(y) - rect.origin.y) / scaleY),
                color: .init(
                    r: color[0],
                    g: color[1],
                    b: color[2],
                    a: color[3]
                )
            )
        }

        return nil
    }

    public func sizeToFit() {
        self.setFrameSize(self.intrinsicContentSize)
    }

    public func updateDrawableSize() {
        let s = self.backingScaleFactor
        self.drawableSize = .init(width: self.bounds.width * s, height: self.bounds.height * s)
    }

    // MARK: - NSView

    public override var frame: NSRect {
        didSet {
            self.updateDrawableSize()
        }
    }

    public override var intrinsicContentSize: NSSize {
        if let image = self.image {
            image.extent.size
        } else {
            .zero
        }
    }

    public override func viewDidChangeBackingProperties() {
        self.updateDrawableSize()
    }

    public override func viewDidMoveToSuperview() {
        self.updateDrawableSize()
    }

    public override func updateTrackingAreas() {
        if let ta = self.trackingArea {
            self.removeTrackingArea(ta)
        }
        let trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(trackingArea)
        self.trackingArea = trackingArea

        super.updateTrackingAreas()
    }

    public override func mouseMoved(with event: NSEvent) {
        if let onMouseOver = self.onMouseOver {
            onMouseOver(self.getPixelInfo(self.convert(event.locationInWindow, from: nil)))
        }
    }

    public override func mouseExited(with event: NSEvent) {
        if let onMouseOver = self.onMouseOver {
            onMouseOver(nil)
        }
    }
}

// MARK: - MTKViewDelegate

extension CIImageNSView: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.needsDisplay = true
    }

    public func draw(in view: MTKView) {
        guard let image = self.image else { return }

        guard let commandBuffer = self.commandQueue.makeCommandBuffer(), let rpd = self.currentRenderPassDescriptor
        else { return }
        rpd.colorAttachments[0].loadAction = .clear
        let enc = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)!
        enc.endEncoding()

        let scaledImage: CIImage =
            switch self.resizeMode {
            case .none:
                image
            case .stretch:
                image
                    .transformed(
                        by: .init(
                            scaleX: self.bounds.width / image.extent.width,
                            y: self.bounds.height / image.extent.height
                        )
                    )
            case .fit:
                {
                    let scale = min(self.bounds.width / image.extent.width, self.bounds.height / image.extent.height)
                    return image.transformed(by: .init(scaleX: scale, y: scale))
                }()
            case .fill:
                {
                    let scale = max(self.bounds.width / image.extent.width, self.bounds.height / image.extent.height)
                    return image.transformed(by: .init(scaleX: scale, y: scale))
                }()
            }

        let finalImage =
            scaledImage
            // .samplingNearest()
            .transformed(by: .init(scaleX: self.backingScaleFactor, y: self.backingScaleFactor))

        let size = CGSize(
            width: self.bounds.size.width * self.backingScaleFactor,
            height: self.bounds.size.height * self.backingScaleFactor
        )

        let rd = CIRenderDestination(
            width: Int(size.width),
            height: Int(size.height),
            pixelFormat: self.colorPixelFormat,
            commandBuffer: commandBuffer,
            mtlTextureProvider: {
                // self?.lastDrawableTexture = view.currentDrawable!.texture
                return view.currentDrawable!.texture
            }
        )

        let point: CGPoint =
            switch self.alignment {
            case .center:
                .init(
                    x: (self.bounds.width / 2) * self.backingScaleFactor - finalImage.extent.width / 2,
                    y: (self.bounds.height / 2) * self.backingScaleFactor - finalImage.extent.height / 2
                )

            case .top:
                .init(
                    x: (self.bounds.width / 2) * self.backingScaleFactor - finalImage.extent.width / 2,
                    y: self.bounds.height * self.backingScaleFactor - finalImage.extent.height
                )

            case .topLeft:
                .init(
                    x: 0,
                    y: self.bounds.height * self.backingScaleFactor - finalImage.extent.height
                )

            case .topRight:
                .init(
                    x: self.bounds.width * self.backingScaleFactor - finalImage.extent.width,
                    y: self.bounds.height * self.backingScaleFactor - finalImage.extent.height
                )

            case .bottom:
                .init(
                    x: (self.bounds.width / 2) * self.backingScaleFactor - finalImage.extent.width / 2,
                    y: 0
                )

            case .bottomLeft:
                .init(
                    x: 0,
                    y: 0
                )

            case .bottomRight:
                .init(
                    x: self.bounds.width * self.backingScaleFactor - finalImage.extent.width,
                    y: 0
                )

            case .left:
                .init(
                    x: 0,
                    y: (self.bounds.height / 2) * self.backingScaleFactor - finalImage.extent.height / 2
                )

            case .right:
                .init(
                    x: self.bounds.width * self.backingScaleFactor - finalImage.extent.width,
                    y: (self.bounds.height / 2) * self.backingScaleFactor - finalImage.extent.height / 2
                )
            }

        // var task: CIRenderTask!
        do {
            try self.context.startTask(
                toRender: finalImage,
                from: finalImage.extent,
                to: rd,
                at: point
            )
        } catch {
            print("CIImageNSView error: \(error)")
        }

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()

        self.lastDrawnRect = .init(origin: point, size: finalImage.extent.size)

        // try! task.waitUntilCompleted()
    }
}
