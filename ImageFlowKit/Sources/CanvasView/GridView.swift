import ColorUtils
import CommonUtils
import Design
import Logging
import PlatformUtils

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public final class GridView: PlatformView {

    var viewport: CanvasViewport?

    #if os(macOS)
    var onEvent: ((Event) -> ())?

    enum Event {
        case scroll(NSEvent)
        case mouseEntered
        case mouseLeft
    }
    #endif

    init() {
        super.init(frame: .zero)
        self.platformInit()
        self.setupShapeLayers()
    }

    required init?(coder: NSCoder) {
        nil
    }

    #if os(macOS)
    func platformInit() {
        self.wantsLayer = true
    }
    #endif

    #if os(iOS)
    func platformInit() {
        self.backgroundColor = BackgroundStyle.default.bg.platformColor  //Colors.canvasBackground.platformColor
        self.setNeedsDisplay()
    }
    #endif

    // MARK: - Drawing

    #if os(macOS)
    public override var isFlipped: Bool {
        true
    }
    #endif

    /// Schedule this view for drawing with the give viewport state and list of edges.
    ///
    /// - Parameter viewport: The viewport state.
    /// - Parameter edges: The list of edges to be drawn.
    // func draw(viewport: CanvasViewport, edges: [EdgeLayer]) {
    func draw(viewport: CanvasViewport, edges: [EdgeLayer]) {
        log("draw: viewport: \(viewport), edges: \(edges)", level: .debug)
        self.viewport = viewport
        self.edgesLayersToDraw = edges
        #if os(macOS)
        self.needsDisplay = true
        #else
        self.setNeedsDisplay()
        #endif
        self.clipsToBounds = true
    }

    #if os(macOS)
    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        if let viewport = self.viewport, let layer = self.layer {
            self.drawBackgroundTiles(context, layer, viewport)
        }
        self.drawEdges(context)
    }
    #endif

    #if os(iOS)
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        if let viewport = self.viewport {
            self.drawBackgroundEllipses(context, self.layer, viewport)
        }
        self.drawEdges(context)
    }
    #endif

    var edgesLayersToDraw: [EdgeLayer] = []

    var edgeShapeLayers: [CAShapeLayer] = []

    var curves: [UUID: (EdgeCurve, Int)] = [:]

    private func setupShapeLayers() {
        for _ in 0..<10 {
            let layer = CAShapeLayer()
            layer.fillColor = nil
            layer.strokeColor = Colors.portConnected.cgColor
            layer.lineWidth = 4.0
            #if os(macOS)
            layer.delegate = self
            #endif
            self.layer().addSublayer(layer)
            self.edgeShapeLayers.append(layer)
        }
    }

    private func drawEdges(_ ctx: CGContext) {
        log("drawing edges: \(self.edgesLayersToDraw)")
        guard let viewport = self.viewport else {
            log("Viewport is missing!", level: .warning)
            return
        }

        self.curves.removeAll()

        if self.edgesLayersToDraw.count > self.edgeShapeLayers.count {
            fatalError("Insufficient edge shape layers!")
        }

        for layer in edgeShapeLayers {
            layer.path = nil
        }

        for (idx, edgeLayer) in self.edgesLayersToDraw.enumerated() {
            let edgesPath = {
                let path = CGMutablePath()

                for edge in edgeLayer.edges {
                    let curve = EdgeCurve(start: edge.src, end: edge.dst, withViewport: viewport)
                    curve.addToPath(path)
                    self.curves[edge.id] = (curve, idx)
                }

                return path
            }()

            let edgeWidth = viewport.convert(4.0, from: .canvas, to: .screen)

            let layer = self.edgeShapeLayers[idx]

            layer.lineCap = .round
            layer.lineWidth = edgeWidth
            layer.path = edgesPath
            layer.strokeColor = edgeLayer.color.cgColor
        }
    }

    #if os(macOS)
    public override func scrollWheel(with event: NSEvent) {
        self.onEvent?(.scroll(event))
    }
    #endif

    struct BackgroundStyle: With {
        var spacing: CGFloat
        var radius: CGFloat
        var fg: DynamicColor
        var bg: DynamicColor
        var dotFadeCuttoff: CGFloat

        static let `default`: Self = {
            .init(
                spacing: 25.0,
                radius: 1.0,
                fg: Colors.canvasBackgroundDot,
                bg: Colors.canvasBackground,
                dotFadeCuttoff: 0.5,
            )
        }()
    }

    func makeTile(_ size: CGFloat, _ radius: CGFloat, _ bg: CGColor, _ fg: CGColor) -> CGImage {
        // Define the image size
        let imageSize = CGSize(width: size, height: size)

        // Define the circle's properties
        let circleRadius: CGFloat = radius
        let circleCenter = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)

        // Create a bitmap context
        let context = CGContext(
            data: nil,
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: 8,  // 8 bits per color component
            bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        // Fill the background with white
        context.setFillColor(bg)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // Draw the black circle
        context.setFillColor(fg)
        context.fillEllipse(
            in: CGRect(
                x: circleCenter.x - circleRadius,
                y: circleCenter.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
        )

        // Create the CGImage from the context
        return context.makeImage()!
    }

    func calcDotColor(_ style: BackgroundStyle, _ scale: CGFloat) -> (CGColor, CGFloat) {
        let t = ((1.0 / (style.dotFadeCuttoff - 1.0)) * (scale - 1.0)).clamped(to: 0...1)
        let dotColor = {
            let start = HSL(cgColor: style.fg.cgColor)!
            let end = HSL(cgColor: style.bg.cgColor)!
            return start.lerp(to: end, channelMask: [.hue, .lightness, .saturation], t: t).cgColor
        }()
        return (dotColor, t)
    }

    func drawBackgroundTiles(_ ctx: CGContext, _ layer: CALayer, _ viewport: CanvasViewport) {
        let style = BackgroundStyle.default

        layer.backgroundColor = style.bg.cgColor

        let imageSize = style.spacing
        let size = viewport.convert(imageSize, from: .canvas, to: .screen)
        let offsetX = -viewport.origin.x.truncatingRemainder(dividingBy: imageSize)
        let offsetY = -viewport.origin.y.truncatingRemainder(dividingBy: imageSize)
        let offset = viewport.convert(.init(width: offsetX, height: offsetY), from: .canvas, to: .screen)
        let (dotColor, t) = self.calcDotColor(style, viewport.scale)
        let tile = self.makeTile(
            size * layer.contentsScale,
            viewport.convert(style.radius, from: .canvas, to: .screen) * layer.contentsScale,
            style.bg.cgColor,
            dotColor
        )

        log("offset: \(offset), size: \(size)")

        if t <= style.dotFadeCuttoff {
            ctx.draw(
                tile,
                in: .init(origin: .init(x: offset.width, y: offset.height), size: .init(width: size, height: size)),
                byTiling: true
            )
        }
    }

    func drawBackgroundEllipses(_ ctx: CGContext, _ layer: CALayer, _ viewport: CanvasViewport) {
        let style = BackgroundStyle.default

        layer.backgroundColor = style.bg.cgColor
        let (dotColor, t) = self.calcDotColor(style, viewport.scale)
        ctx.setFillColor(dotColor)

        if t > style.dotFadeCuttoff {
            return
        }

        let canvasViewRect = viewport.convert(CGRect(origin: .zero, size: self.bounds.size), from: .screen, to: .canvas)

        let spacing = style.spacing
        let radius = style.radius

        let i: Int = Int(canvasViewRect.origin.x / spacing) - 1
        let j: Int = Int(canvasViewRect.origin.y / spacing) - 1
        let imax: Int = Int(canvasViewRect.maxX / spacing)
        let jmax: Int = Int(canvasViewRect.maxY / spacing)

        for i in i...imax {
            for j in j...jmax {
                let p = viewport.convert(
                    .init(
                        x: CGFloat(i) * spacing + (spacing * 0.5 - radius),
                        y: CGFloat(j) * spacing + (spacing * 0.5 - radius)
                    ),
                    from: .canvas,
                    to: .screen
                )
                let size = viewport.convert(2 * radius, from: .canvas, to: .screen)
                ctx.fillEllipse(in: .init(x: p.x, y: p.y, width: size, height: size))
            }
        }
    }
}

#if os(macOS)
extension GridView: CALayerDelegate {

}
#endif
