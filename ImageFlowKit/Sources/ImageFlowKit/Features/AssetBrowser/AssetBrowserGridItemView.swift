import CoreGraphics
import SwiftUI
import Logging

extension AssetBrowserView {
    struct ImageAssetInfo: Equatable, Identifiable {
        var id: UUID
        var name: String
        var added: Date
        var state: State = .loading

        enum State: Equatable {
            case loading
            case loaded
            case failed
        }
    }

    protocol AssetProvider {
        func getThumb(id: UUID, width: Int, height: Int) async throws -> CGImage
        var images: [ImageAssetInfo] { get }
    }

    class PreviewAssetProvider: AssetProvider {
        let ids: [UUID]
        internal init(ids: [UUID]) {
            self.ids = ids
        }

        func getThumb(id: UUID, width: Int, height: Int) async throws -> CGImage {
            makeTestPatternCGImage(width: width, height: height)!
        }

        var images: [ImageAssetInfo] {
            self.ids.map { id in
                .init(id: id, name: id.uuidString, added: .now, state: .loaded)
            }
        }
    }
}

extension AssetBrowserView {
    struct GridItemView: View {
        // let assetManager: AssetManager
        let assetProvider: any AssetProvider
        let selected: Bool

        @State var image: CGImage?
        let info: ImageAssetInfo

        var body: some View {
            GridItemInnerView(
                image: self.image,
                name: info.name,
                selected: self.selected,
                failed: self.info.state == .failed
            )
            .onChange(of: self.info, initial: true) {
                Task {
                    await self.fetchImage()
                }
            }
        }

        func fetchImage() async {
            do {
                self.image = try await self.assetProvider.getThumb(id: self.info.id, width: 110 * 2, height: 110 * 2)
            } catch {
                log("Failed to fetch image: \(error)", level: .error)
            }
        }
    }
}

#Preview {
    let id = UUID()
    AssetBrowserView.GridItemView(
        assetProvider: AssetBrowserView.PreviewAssetProvider(ids: [id]),
        selected: false,
        image: nil,
        info: .init(id: id, name: "", added: .now)
    )
    .frame(width: 146, height: 146)
    .background(.white)
    .padding(10)
}

/// Creates an 8-bpc sRGB, premultiplied-alpha CGImage test pattern.
/// Pattern: top = color bars, middle = checkerboard, bottom = grayscale ramp, with crosshair & rings.
public func makeTestPatternCGImage(width: Int, height: Int) -> CGImage? {
    guard width > 0, height > 0 else { return nil }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue

    guard
        let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
    else {
        return nil
    }

    let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))

    // Background: subtle vertical gray gradient
    if let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceGray(),
        colors: [CGColor(gray: 0.18, alpha: 1), CGColor(gray: 0.06, alpha: 1)] as CFArray,
        locations: [0, 1]
    ) {
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.minX, y: rect.maxY),
            end: CGPoint(x: rect.minX, y: rect.minY),
            options: []
        )
    } else {
        ctx.setFillColor(gray: 0.1, alpha: 1)
        ctx.fill(rect)
    }

    // Top: simplified SMPTE-like color bars
    let topH = rect.height * 0.28
    let barColors: [(CGFloat, CGFloat, CGFloat)] = [
        (1, 1, 1),  // white
        (1, 1, 0),  // yellow
        (0, 1, 1),  // cyan
        (0, 1, 0),  // green
        (1, 0, 1),  // magenta
        (1, 0, 0),  // red
        (0, 0, 1),  // blue
    ]
    let barW = rect.width / CGFloat(barColors.count)
    for (i, rgb) in barColors.enumerated() {
        let r = CGRect(
            x: CGFloat(i) * barW,
            y: rect.maxY - topH,
            width: i == barColors.count - 1 ? rect.maxX - CGFloat(i) * barW : barW + 1,
            height: topH
        )
        ctx.setFillColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
        ctx.fill(r)
    }

    // Middle: checkerboard (light/dark gray)
    let midRect = CGRect(
        x: rect.minX,
        y: rect.height * 0.35,
        width: rect.width,
        height: rect.height * 0.35
    )

    let cell = max(8.0, min(64.0, min(midRect.width, midRect.height) / 10.0))
    var y = midRect.minY
    var rowStartDark = false
    while y < midRect.maxY {
        var x = midRect.minX
        rowStartDark.toggle()
        var dark = rowStartDark
        while x < midRect.maxX {
            ctx.setFillColor(gray: dark ? 0.25 : 0.75, alpha: 1)
            ctx.fill(
                CGRect(
                    x: x,
                    y: y,
                    width: min(cell, midRect.maxX - x),
                    height: min(cell, midRect.maxY - y)
                )
            )
            x += cell
            dark.toggle()
        }
        y += cell
    }

    // Bottom: 16-step grayscale ramp
    let rampRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.2)
    let steps = 16
    let stepW = rampRect.width / CGFloat(steps)
    for i in 0..<steps {
        let g = CGFloat(i) / CGFloat(steps - 1)
        ctx.setFillColor(gray: g, alpha: 1)
        ctx.fill(
            CGRect(
                x: CGFloat(i) * stepW,
                y: rampRect.minY,
                width: i == steps - 1 ? rampRect.maxX - CGFloat(i) * stepW : stepW + 1,
                height: rampRect.height
            )
        )
    }

    // Crosshair & concentric rings (alignment/focus cues)
    let center = CGPoint(x: rect.midX, y: rect.midY)
    ctx.setLineWidth(1)

    ctx.setStrokeColor(gray: 1, alpha: 0.8)
    ctx.move(to: CGPoint(x: center.x, y: rect.minY))
    ctx.addLine(to: CGPoint(x: center.x, y: rect.maxY))
    ctx.move(to: CGPoint(x: rect.minX, y: center.y))
    ctx.addLine(to: CGPoint(x: rect.maxX, y: center.y))
    ctx.strokePath()

    ctx.setStrokeColor(gray: 1, alpha: 0.5)
    let maxR = min(rect.width, rect.height) * 0.45
    for i in 1...5 {
        let r = maxR * CGFloat(i) / 5.0
        ctx.strokeEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r))
    }

    // Border
    ctx.setStrokeColor(gray: 0, alpha: 1)
    ctx.setLineWidth(2)
    ctx.stroke(rect.insetBy(dx: 1, dy: 1))

    return ctx.makeImage()
}
