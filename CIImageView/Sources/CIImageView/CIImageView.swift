import AppKit
import SwiftUI

public struct CIImageView: NSViewRepresentable {

    public var image: CIImage?
    public var resizeMode: CIImageNSView.ResizeMode = .none
    public var alignment: CIImageNSView.Alignment = .center
    public var pixelInfo: Binding<CIImageNSView.PixelInfo?>? = nil

    public init(
        image: CIImage? = nil,
        resizeMode: CIImageNSView.ResizeMode = .none,
        alignment: CIImageNSView.Alignment = .center,
        pixelInfo: Binding<CIImageNSView.PixelInfo?>? = nil
    ) {
        self.image = image
        self.resizeMode = resizeMode
        self.alignment = alignment
        self.pixelInfo = pixelInfo
    }

    public func makeNSView(context: Context) -> CIImageNSView {
        let view = CIImageNSView(frame: .zero)
        if let pixelInfo = self.pixelInfo {
            view.onMouseOver = { info in
                pixelInfo.wrappedValue = info
            }
        }
        return view
    }

    public func updateNSView(_ view: CIImageNSView, context: Context) {
        if self.image != view.image {
            view.image = self.image
        }

        if view.resizeMode != self.resizeMode {
            view.resizeMode = self.resizeMode
        }

        if view.alignment != self.alignment {
            view.alignment = self.alignment
        }
        if let pixelInfo = self.pixelInfo {
            view.onMouseOver = { info in
                pixelInfo.wrappedValue = info
            }
        }
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: CIImageNSView, context: Context) -> CGSize? {
        if let width = proposal.width, let height = proposal.height {
            return .init(width: width, height: height)
        } else {
            return nil
        }
    }
}
