import CoreGraphicsEx
import CoreImage
import MetalKit
import OSLog
import XViewKit
import os

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public class CIImageXView: XCommonView {

    public var image: CIImage? {
        didSet {
            if self.image != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    public var placement: ImagePlacement = .manual(scale: .init(width: 1, height: 1), offset: .zero) {
        didSet {
            if self.placement != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    public private(set) var imageScale: CGSize = .init(width: 1, height: 1)
    public private(set) var offset: CGPoint = .zero
    public private(set) var renderInfo: CIRenderInfo?

    private let device: MTLDevice
    private var renderer: Renderer

    public var drawableSize: CGSize {
        self.metalLayer.drawableSize
    }

    public override var intrinsicContentSize: CGSize {
        self.imageLogicalSize
    }

    public override init(frame: CGRect) {
        self.device = MTLCreateSystemDefaultDevice()!
        self.renderer = .init(self.device)
        // self.threadedRenderer = .init(self.device)

        super.init(frame: frame)

        self.platformInit()

        self.metalLayer.device = self.device
        self.metalLayer.framebufferOnly = false
        self.metalLayer.pixelFormat = .rgba8Unorm
        self.metalLayer.presentsWithTransaction = true
        self.metalLayer.needsDisplayOnBoundsChange = true
        self.metalLayer.delegate = self
        self.metalLayer.magnificationFilter = .nearest
        self.metalLayer.minificationFilter = .trilinear
        self.metalLayer.isOpaque = false
    }

    @available(*, unavailable)
    public required init(coder: NSCoder) {
        fatalError("Not implemented!")
    }

    #if os(macOS)
    public override func makeBackingLayer() -> CALayer {
        CAMetalLayer()
    }

    private func platformInit() {
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layerContentsPlacement = .bottomLeft
    }

    public var metalLayer: CAMetalLayer {
        self.layer! as! CAMetalLayer
    }

    public override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        self.resizeDrawable()
    }

    public override func setBoundsSize(_ newSize: NSSize) {
        super.setBoundsSize(newSize)
        self.resizeDrawable()
    }

    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.resizeDrawable()
        self.metalLayer.contentsScale = self.contentScale
    }

    public override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        self.resizeDrawable()
        self.metalLayer.contentsScale = self.contentScale
    }
    #endif

    #if os(iOS)

    public override class var layerClass: AnyClass {
        CAMetalLayer.self
    }

    var metalLayer: CAMetalLayer {
        self.layer as! CAMetalLayer
    }

    func platformInit() {
    }

    var contentScale: CGFloat {
        self.contentScaleFactor
    }

    public override func draw(_ rect: CGRect) {
        self.render()
    }

    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        self.render()
    }

    public override func display(_ layer: CALayer) {
        self.render()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        self.resizeDrawable()
        self.metalLayer.contentsScale = self.contentScale
    }

    public override var frame: CGRect {
        didSet {
            self.resizeDrawable()
        }
    }

    public override var bounds: CGRect {
        didSet {
            self.resizeDrawable()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.resizeDrawable()
    }

    public override var contentScaleFactor: CGFloat {
        didSet {
            self.resizeDrawable()
            self.metalLayer.contentsScale = self.contentScaleFactor
        }
    }
    #endif

    public var imagePixelSize: CGSize {
        self.image?.extent.size ?? .zero
    }

    public var imageLogicalSize: CGSize {
        self.imagePixelSize / self.contentScale
    }

    public var boundsPixelSize: CGSize {
        self.bounds.size * self.contentScale
    }

    public func convertToPixel(_ point: CGPoint) -> CGPoint {
        point * self.contentScale
    }

    public func convertToPixel(_ size: CGSize) -> CGSize {
        size * self.contentScale
    }

    private func updatePlacement() {
        switch self.placement {
        case .manual(let scale, let offset):
            self.imageScale = scale
            self.offset.x = offset.x
            self.offset.y = self.drawableSize.height - self.imagePixelSize.height * scale.height - offset.y
        case .center:
            let imageSize = self.image?.extent.size ?? .zero
            self.imageScale = .init(width: 1, height: 1)
            self.offset = .init(
                x: (self.drawableSize.width - imageSize.width) * 0.5,
                y: (self.drawableSize.height - imageSize.height) * 0.5
            )
            break
        case .stretch:
            let imageSize = self.image?.extent.size ?? .zero
            let ds = self.drawableSize
            self.imageScale = .init(width: ds.width / imageSize.width, height: ds.height / imageSize.height)
            self.offset = .zero
        case .fit:
            if let image = self.image {
                let sx = self.drawableSize.height / image.extent.height
                let sy = self.drawableSize.width / image.extent.width
                let scale = min(sx, sy)
                let offset = CGPoint(
                    x: (self.drawableSize.width - image.extent.width * scale) * 0.5,
                    y: (self.drawableSize.height - image.extent.height * scale) * 0.5
                )
                self.imageScale = .init(width: scale, height: scale)
                self.offset = offset
            }
        case .fill:
            if let image = self.image {
                let sx = self.drawableSize.height / image.extent.height
                let sy = self.drawableSize.width / image.extent.width
                let scale = max(sx, sy)
                let offset = CGPoint(
                    x: (self.drawableSize.width - image.extent.width * scale) * 0.5,
                    y: (self.drawableSize.height - image.extent.height * scale) * 0.5
                )
                self.imageScale = .init(width: scale, height: scale)
                self.offset = offset
            }
        }
    }

    func resizeDrawable() {
        let newSize = self.boundsPixelSize

        if newSize.width <= 0 || newSize.height <= 0 {
            return
        }

        if newSize != self.metalLayer.drawableSize {
            self.metalLayer.drawableSize = newSize
        }
    }

    var isZoomedIn: Bool {
        self.imageScale.width > 1 || self.imageScale.height > 1
    }

    func doRender() {
        self.updatePlacement()
        let renderData = RenderData(
            image: self.image,
            drawableSize: self.drawableSize,
            pixelFormat: self.metalLayer.pixelFormat,
            isZoomedIn: self.isZoomedIn,
            imageScale: self.imageScale,
            offset: self.offset
        )
        if self.drawableSize.width <= 0 || self.drawableSize.height <= 0 { return }
        self.renderer.render(
            renderData,
            { [weak self] in
                self?.metalLayer.nextDrawable()
            }
        )
        // self.threadedRenderer.render(renderData, self.metalLayer.nextDrawable())
    }
}

#if os(macOS)
extension CIImageXView: @MainActor CALayerDelegate {
    public func draw(_ layer: CALayer, in ctx: CGContext) {
        sp.emitEvent("CIImageXView:draw")
        self.doRender()
    }

    public func display(_ layer: CALayer) {
        sp.emitEvent("CIImageXView:display")
        self.doRender()
    }
}

extension CIImageXView {
    public func setNeedsDisplay() {
        self.needsDisplay = true
    }

    public override var isFlipped: Bool {
        true
    }
}
#endif

public enum ImagePlacement: Equatable {
    /// Position the image manually with the given `scale` and `offset`.
    case manual(scale: CGSize, offset: CGPoint)
    /// Place the image unscaled in the center of the view.
    case center
    /// Scale the image to completely fill the view while maintaining the
    /// image's aspect ratio.
    case fill
    /// Scale the image to fit inside the view while maintaining the
    /// image's aspect ratio.
    case fit
    /// Scale the image to completely fill the view without maintaining the
    /// image's aspect ratio.
    case stretch

    public mutating func updateManual(f: (CGSize, CGPoint) -> ((CGSize, CGPoint))) {
        switch self {
        case .manual(scale: let scale, offset: let offset):
            let (scale, offset) = f(scale, offset)
            self = .manual(scale: scale, offset: offset)
        default:
            break
        }
    }
}
