import CoreGraphicsEx
import CoreImage
import Foundation
import XViewKit

#if canImport(AppKit)
import AppKit
public typealias CIImageScrollXView = CIImageScrollNSView
#endif

#if canImport(UIKit)
import UIKit
public typealias CIImageScrollXView = CIImageScrollUIView
#endif

protocol CIImageScrollXViewProtocol: XView {
    var id: String { get set }
    var image: CIImage? { get set }
    var zoom: CGFloat { get }
    var cache: (any CIImageScrollViewCache)? { get set }
    var onEvent: ((CIImageScrollXView.Event) -> ())? { get set }
    var isAnimating: Bool { get }
    var imageView: CIImageXView { get }
    var viewportRestoreState: ViewportRestoreState { get }

    init(
        frame: CGRect,
        id: String,
        configuration: CIImageScrollXView.Configuration,
        cache: (any CIImageScrollViewCache)?
    )

    func dispatch(_ action: CIImageScrollXView.Action)
}

extension CIImageScrollXView {

    public enum Event {
        case zoomDidChange(CGFloat)
    }

    public enum Action: Equatable {
        case zoomToFit(animate: Bool)
        case actualSize(animate: Bool)
        case zoomIn(animate: Bool)
        case zoomOut(animate: Bool)
        case setZoom(value: CGFloat, center: CGPoint? = nil, animate: Bool)
        case cacheSave
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

    func viewportStateInput(_ input: ViewportRestoreState.Input) {
        if let output = self.viewportRestoreState.input(input) {
            switch output {
            case .zoomToFit: self.dispatch(.zoomToFit(animate: false))
            case .actualSize: self.dispatch(.actualSize(animate: false))
            case .setZoom(let zoom): self.dispatch(.setZoom(value: zoom, center: nil, animate: false))
            case .restore(let entry): self.cacheRestore(entry)
            }
        }
    }

    func cacheSave() {
        self.cache?.set(
            id: self.id,
            value: self.cacheEntry()
        )
    }

    @discardableResult
    func cacheRestore() -> Bool {
        if let entry = self.cache?.get(id: self.id) {
            self.cacheRestore(entry)
            return true
        }

        return false
    }

    func willSetId(_ newValue: String) {
        if newValue != self.id {
            self.cacheSave()
        }
    }

    func didSetId(_ oldValue: String) {
        if self.id != oldValue {
            self.viewportStateInput(.didChangeID)
            self.setNeedsLayout()
        }
    }
}

struct ViewportRestoreState {
    var state: State
    var initial: CIImageScrollView.Configuration.InitialViewport
    let fitAdjustmentTimeout: Double = 0.25

    enum State {
        case idle
        case adjusting(Date)
        case done
    }

    enum Input {
        case layoutOrImageChange(id: String, (any CIImageScrollViewCache)?)
        case frameDidSet
        case didChangeID
    }

    enum Output {
        case zoomToFit
        case actualSize
        case setZoom(CGFloat)
        case restore(CIImageScrollView.CacheEntry)
    }

    init(_ configuration: CIImageScrollXView.Configuration) {
        self.state = .idle
        self.initial = configuration.initialViewport
    }

    mutating func input(_ input: Input) -> Output? {
        switch input {
        case .frameDidSet:
            self.frameDidSet()
        case .layoutOrImageChange(let id, let cache):
            self.layout(id, cache)
        case .didChangeID:
            self.didChangeID()
        }
    }

    mutating func didChangeID() -> Output? {
        switch self.state {
        case .idle:
            return nil
        case .adjusting(_):
            self.state = .idle
            return nil
        case .done:
            self.state = .idle
            return nil
        }
    }

    mutating func layout(_ id: String, _ cache: (any CIImageScrollViewCache)?) -> Output? {
        switch self.state {
        case .idle:
            if let cache, let entry = cache.get(id: id) {
                self.state = .done
                return .restore(entry)
            } else {
                switch self.initial {
                case .fit:
                    self.state = .adjusting(.now)
                    return .zoomToFit
                case .actualSize:
                    self.state = .done
                    return .actualSize
                case .centered(zoom: let zoom):
                    self.state = .done
                    return .setZoom(zoom)
                }
            }
        case .adjusting(_):
            if let cache, let entry = cache.get(id: id) {
                self.state = .done
                return .restore(entry)
            } else {
                return nil
            }
        case .done:
            return nil
        }
    }

    mutating func frameDidSet() -> Output? {
        switch self.state {
        case .idle:
            return nil
        case .adjusting(let start):
            if Date.now.timeIntervalSince(start) > self.fitAdjustmentTimeout {
                self.state = .done
                return nil
            } else {
                return .zoomToFit
            }
        case .done:
            return nil
        }
    }

}
