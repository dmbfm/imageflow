import CoreImage
import Foundation
import Helpers
import XKit

#if canImport(AppKit)
import AppKit
public typealias CIImageScrollXView = CIImageScrollNSView
#endif

#if canImport(UIKit)
import UIKit
public typealias CIImageScrollXView = CIImageScrollUIView
#endif

protocol CIImageScrollXViewProtocol: XView {
    var image: CIImage? { get set }
    var zoom: CGFloat { get }
    var isAnimating: Bool { get }
    var imageView: CIImageXView { get }
    var delegate: CIImageScrollXViewDelegate? { get set }

    init(
        frame: CGRect,
        configuration: CIImageScrollXView.Configuration,
    )

    func dispatch(_ action: CIImageScrollXView.Action)
}

public protocol CIImageScrollXViewDelegate: AnyObject {
    func ciImageScrollViewViewportDidChange(_ view: CIImageScrollXView, _ viewport: CGRect)
    func ciImageScrollViewZoomDidChange(_ view: CIImageScrollXView, _ zoom: CGFloat)
}

extension CIImageScrollXView {
    public enum Action: Equatable {
        case zoomToFit(animate: Bool)
        case zoomToFitSize(CGSize, animate: Bool)
        case actualSize(animate: Bool)
        case zoomIn(animate: Bool)
        case zoomOut(animate: Bool)
        case setZoom(value: CGFloat, center: CGPoint? = nil, animate: Bool)
    }

    public struct Configuration {
        public var mousePan: MousePan
        public var scrollWheelZoom: ScrollWheelZoom
        public var zoomRange: ClosedRange<CGFloat>
        public var initialViewport: InitialViewport

        public enum InitialViewport: Equatable {
            case fit
            case actualSize
            case centered(zoom: CGFloat)
        }

        public enum MousePan {
            case disabled
            case enabled(button: XMouseButton, modifiers: XModifierFlags)
        }

        public enum ScrollWheelZoom {
            case disabled
            case enabled(sensitivity: CGFloat)
        }

        public init(
            mousePan: MousePan = .enabled(button: .other, modifiers: []),
            scrollWhellZoom: ScrollWheelZoom = .enabled(sensitivity: 0.25),
            zoomRange: ClosedRange<CGFloat> = 0.1...1000,
            initialViewport: InitialViewport = .fit
        ) {
            self.mousePan = mousePan
            self.scrollWheelZoom = scrollWhellZoom
            self.zoomRange = zoomRange
            self.initialViewport = initialViewport
        }

        public func zoomIn(_ zoom: CGFloat) -> CGFloat {
            let alpha = log2(zoom)
            let nextAlpha = ceil(alpha) + 1
            let result = pow(2.0, nextAlpha)
            if self.zoomRange.contains(result) {
                return result
            } else {
                return zoom
            }
        }

        public func zoomOut(_ zoom: CGFloat) -> CGFloat {
            let alpha = log2(zoom)
            let nextAlpha = ceil(alpha) - 1
            let result = pow(2.0, nextAlpha)
            if self.zoomRange.contains(result) {
                return result
            } else {
                return zoom
            }
        }
    }
}
