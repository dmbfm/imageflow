import ColorUtils
import CommonUtils
import Design
import Logging
import SwiftUI

public struct GridView: View, @preconcurrency Equatable {

    let configuration: CanvasConfiguration
    @Binding var viewport: CanvasViewport
    @State var circleImageDrawer = CircleImageDrawer()

    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Equatable

    public static func == (lhs: GridView, rhs: GridView) -> Bool {
        lhs.viewport == rhs.viewport
    }

    // MARK: - Initializers

    public init(viewport: Binding<CanvasViewport>, configuration: CanvasConfiguration = .default) {
        self._viewport = viewport
        self.configuration = configuration
    }

    // MARK: - Methods

    func draw(_ context: inout GraphicsContext, _ size: CGSize) {
        context.withCGContext { cgContext in
            let imageSize: CGFloat = 40 / self.displayScale
            let size = self.viewport.convert(imageSize, from: .canvas, to: .screen)
            let offsetX = -viewport.origin.x.truncatingRemainder(dividingBy: imageSize)
            let offsetY = -viewport.origin.y.truncatingRemainder(dividingBy: imageSize)
            let offset = viewport.convert(CGSize(width: offsetX, height: offsetY), from: .canvas, to: .screen)

            let t = 1.0 - viewport.scale.clamped(to: 0.0...1.0)
            let dotColor = HSL(cgColor: Colors.canvasBackgroundDot.cgColor)!.lerp(
                to: HSL(cgColor: Colors.canvasBackground.cgColor)!,
                channelMask: [.hue, .lightness, .saturation],
                t: t
            ).cgColor
            let image = self.circleImageDrawer.draw(Colors.canvasBackground.cgColor, dotColor)

            cgContext.draw(
                image,
                in: .init(
                    origin: .init(x: offset.width, y: offset.height),
                    size: .init(width: size, height: size)
                ),
                byTiling: true
            )
        }
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            Canvas(opaque: true, rendersAsynchronously: true, renderer: self.draw(_:_:))
            Text("\(self.viewport.origin)")
        }
        .onChange(of: self.viewport) {
            log("GridView: \(self.viewport)", level: .debug)
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var viewport: CanvasViewport = .init()

    GridView(viewport: $viewport)
        .border(.gray)
        .padding(20)
        .frame(width: 800, height: 600)
}
