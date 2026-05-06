import CoreImage
import Helpers
import OSLog
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
#endif

let sp = OSSignposter(subsystem: "com.dmbfm.ciimageview", category: .pointsOfInterest)

public struct CIImageView: XViewRepresentable {
    var image: CIImage?
    private var placement: ImagePlacement = .center
    private var idealSized: Bool = true

    public func placement(_ placement: ImagePlacement) -> Self {
        var result = self
        result.placement = placement
        result.idealSized = false
        return result
    }

    public func idealSize() -> Self {
        var result = self
        result.placement = .center
        result.idealSized = true
        return result
    }

    @Environment(\.displayScale) var displayScale

    public init(image: CIImage? = nil) {
        self.image = image
    }

    public func makeView(context: Context) -> CIImageXView {
        let view = CIImageXView(frame: .zero)
        view.image = self.image
        view.placement = self.placement
        return view
    }

    public func updateView(_ view: ViewType, context: Context) {
        if view.image != self.image {
            view.image = self.image
        }

        if view.placement != self.placement {
            view.placement = self.placement
        }
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: CIImageXView, context: Context) -> CGSize? {

        guard !self.idealSized else { return nil }

        if let width = proposal.width, let height = proposal.height {
            return CGSize(width: width, height: height)
        } else {
            return nil
        }
    }
}
