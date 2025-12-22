//
//  CIImageScrollUIView.swift
//  CIImageView
//
//  Created by Daniel Fortes on 01/12/25.
//

#if canImport(UIKit)

import CoreGraphicsEx
import CoreImage
import Foundation
import XViewKit
import UIKit

public class CIImageScrollUIView: UIView, CIImageScrollXViewProtocol {

    var id: String {
        willSet {
            if newValue != self.id {
                self.cacheSave()
            }
        }
        didSet {
            if self.id != oldValue {
                self.needsRestoreCache = true
            }
        }
    }

    var cache: (any CIImageScrollViewCache)?

    public var image: CIImage? {
        get {
            self.imageView.image
        }

        set {

            var isDifferentSize = newValue?.extent.size != self.imageView.image?.extent.size

            self.imageView.image = newValue

            if isDifferentSize || self.needsRestoreCache {
                self.scrollView.setZoomScale(1.0, animated: false)
                self.scrollView.setContentOffset(.zero, animated: false)
                self.imageView.frame.size = self.imageView.imageLogicalSize
                self.scrollView.contentSize = self.imageView.imageLogicalSize
            }

            if self.needsRestoreCache {
                if !self.cacheRestore() {
                    switch self.configuration.initialViewport {
                    case .fit:
                        self.dispatch(.zoomToFit(animate: false))
                    case .actualSize:
                        self.dispatch(.actualSize(animate: false))
                    case .centered(zoom: let zoom):
                        self.dispatch(.setZoom(value: zoom, center: nil, animate: false))
                    }
                }
                self.needsRestoreCache = false
            }
        }
    }

    public var zoom: CGFloat {
        self.scrollView.zoomScale
    }

    public var onEvent: ((Event) -> ())?

    private var configuration: Configuration
    private var lastZoom: CGFloat?
    private var needsRestoreCache: Bool = true

    public var isAnimating: Bool {
        self.scrollView.isZoomAnimating || self.scrollView.isScrollAnimating
    }

    public lazy var imageView: CIImageXView = {
        let view = CIImageXView(frame: self.bounds)
        view.placement = .manual(scale: .init(width: 1, height: 1), offset: .zero)
        return view
    }()

    required init(
        frame: CGRect,
        id: String = "",
        configuration: Configuration = .init(),
        cache: (any CIImageScrollViewCache)? = nil
    ) {
        self.configuration = configuration
        self.id = id
        self.cache = cache
        super.init(frame: frame)

        self.addSubview(self.scrollView)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: self.bounds)
        view.minimumZoomScale = self.configuration.zoomRange.lowerBound
        view.maximumZoomScale = self.configuration.zoomRange.upperBound
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = true
        view.backgroundColor = .clear
        view.delegate = self
        view.contentAlignmentPoint = .init(x: 0.5, y: 0.5)
        view.addSubview(self.imageView)
        return view
    }()

    public func actualSize(_ animate: Bool = true) {
        self.scrollView.setZoomScale(1.0, animated: animate)
    }

    public func zoomToFit(_ animate: Bool = true) {
        let b = self.bounds.size
        let i = self.imageView.imageLogicalSize
        let s = min(b.width / i.width, b.height / i.height)
        self.scrollView.setZoomScale(s, animated: animate)
    }

    public func setZoom(value: CGFloat, animate: Bool = true) {
        self.scrollView.setZoomScale(value, animated: animate)
    }

    public func zoomOut(_ animate: Bool = true) {
        self.scrollView.setZoomScale(self.configuration.zoomOut(self.zoom), animated: animate)
    }

    public func zoomIn(_ animate: Bool = true) {
        self.scrollView.setZoomScale(self.configuration.zoomIn(self.zoom), animated: animate)
    }

    public override func layoutSubviews() {
        self.scrollView.frame = self.bounds
    }

    public func dispatch(_ action: Action) {
        switch action {
        case .zoomToFit(let animate):
            self.zoomToFit(animate)
        case .actualSize(let animate):
            self.actualSize(animate)
        case .zoomIn(let animate):
            self.zoomIn(animate)
        case .zoomOut(let animate):
            self.zoomOut(animate)
        case .setZoom(let value, let center, let animate):
            self.setZoom(value: value, animate: animate)
        }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            self.cacheSave()
        }
    }
}

// MARK: - Cache

extension CIImageScrollXView {
    func cacheSave() {
        self.cache?.set(
            id: self.id,
            value: .init(position: self.scrollView.contentOffset, scale: self.scrollView.zoomScale)
        )
    }

    func cacheRestore() -> Bool {
        if let entry = self.cache?.get(id: self.id) {
            self.scrollView.setZoomScale(1.0, animated: false)
            self.scrollView.setContentOffset(.zero, animated: false)
            self.scrollView.setZoomScale(entry.scale, animated: false)
            self.scrollView.setContentOffset(entry.position, animated: false)
            return true
        }

        return false
    }
}

// MARK: - UIScrollViewDelegate

extension CIImageScrollXView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        self.imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.onEvent?(.zoomDidChange(scrollView.zoomScale))
    }
}

#endif
