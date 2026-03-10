//
//  NodeColorPicker.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 02/11/25.
//

import Combine
import Helpers
import Logging
import SwiftUI

// MARK: - AppKit

#if canImport(AppKit)
import AppKit

public final class ColorPickerPlatformView: NSView {

    // MARK: - Exposed Properties

    public var color: NSColor = .red {
        didSet {
            guard self.color != oldValue else { return }

            self.needsDisplay = true

            if let token = self.token {
                ColorPanelManager.shared.setColor(color: self.color, token: token)
            }
        }
    }

    // NOTE: Not used on macOS
    public var commitedColor: NSColor = .red

    public var isLocked: Bool = false {
        didSet {
            if self.isLocked != oldValue {
                if self.isLocked {
                    self.animBorder(to: self.style.borderWidthDefault)
                }
            }
        }
    }

    public var showsAlpha: Bool = true

    public var onEvent: ((Event) -> ())?

    // MARK: - Private Properties

    private let style: Style = .default

    private var trackingArea: NSTrackingArea?

    private var token: ColorPanelManager.Token?

    // MARK: - Subviews

    lazy var bgView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .white
        view.layer?.borderWidth = self.style.borderWidthDefault
        view.layer?.cornerRadius = self.style.radius
        view.layer?.cornerCurve = .continuous
        return view
    }()

    lazy var fgView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = self.style.radius
        view.layer?.cornerCurve = .continuous
        return view
    }()

    // MARK: - Init

    public init() {
        super.init(frame: .zero)

        self.wantsLayer = true

        self.addSubview(self.bgView)
        self.addSubview(self.fgView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Drawing

    public override var wantsUpdateLayer: Bool {
        true
    }

    public override func updateLayer() {
        super.updateLayer()
        self.fgView.layer?.backgroundColor = self.color.cgColor
        self.fgView.layer?.compositingFilter =
            self.effectiveAppearance.isDarkMode ? self.style.darkBlendMode : self.style.lightBlendMode
        self.bgView.layer?.borderColor = self.style.borderColor.cgColor
        self.bgView.layer?.backgroundColor = self.effectiveAppearance.isDarkMode ? .black : .white
    }

    // MARK: - Layout

    public override var isFlipped: Bool {
        true
    }

    public override var intrinsicContentSize: NSSize {
        self.style.size
    }

    public override func layout() {
        super.layout()
        self.bgView.frame = self.bounds
        self.fgView.frame = self.bounds
    }

    // MARK: - User Interaction

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove the old tracking area
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        // Create a new tracking area
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect,
        ]
        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: options,
            owner: self,
            userInfo: nil
        )

        // Add the new tracking area
        addTrackingArea(trackingArea!)
    }

    func animBorder(to value: CGFloat, duration: CGFloat = 0.2) {
        let anim = CABasicAnimation()
        anim.timingFunction = .init(name: .easeInEaseOut)
        anim.fromValue = self.bgView.layer?.borderWidth
        anim.toValue = value
        anim.duration = CFTimeInterval(duration)
        self.bgView.layer?.add(anim, forKey: "borderWidth")
        self.bgView.layer?.borderWidth = value
    }

    public override func mouseEntered(with event: NSEvent) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.style.borderWidthHover)
    }

    public override func mouseExited(with event: NSEvent) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.style.borderWidthDefault)
    }

    private var isMouseDown: Bool = true

    public override func mouseDown(with event: NSEvent) {
        guard !self.isLocked else { return }

        self.isMouseDown = true
        self.animBorder(to: 6, duration: 0.1)
    }

    public override func mouseUp(with event: NSEvent) {
        guard !self.isLocked else { return }

        let pos = self.convert(event.locationInWindow, from: nil)
        if self.isMouseDown && self.bounds.contains(pos) {
            self.clickHandler()
            self.animBorder(to: self.style.borderWidthHover, duration: 0.1)
        } else if self.isMouseDown {
            self.animBorder(to: self.style.borderWidthDefault, duration: 0.2)
        }
        self.isMouseDown = false
    }

    @objc
    func clickHandler() {
        guard !self.isLocked else { return }

        self.token = ColorPanelManager.shared.open(
            initialColor: self.color,
            showsAlpha: self.showsAlpha,
            onChange: { [weak self] newValue in
                self?.emit(.didChange(.init(newValue: newValue)))
            }
        )
    }

    func emit(_ event: Event) {
        log("emit:\(event)")
        self.onEvent?(event)
    }
}
#endif

// MARK: - UIKit

#if canImport(UIKit)
import UIKit

public final class ColorPickerPlatformView: UIView {

    // MARK: - Exposed Properties

    /// The selected color
    public var color: UIColor = .systemRed {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var commitedColor: UIColor = .systemRed

    /// If true, the color picker can edit the color's alpha values
    public var showsAlpha: Bool = true

    public var isLocked: Bool = false {
        didSet {
            if self.isLocked != oldValue {
                if self.isLocked {
                    self.animBorder(to: style.borderWidthDefault)
                }
            }
        }
    }

    public var onEvent: ((Event) -> ())?

    // MARK: - Private Properties

    private var style: Style = .default

    private var isDarkMode: Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }

    // MARK: - Subviews

    lazy var bgView: UIView = {
        let view = UIView()
        view.layer.borderWidth = self.style.borderWidthDefault
        view.layer.cornerRadius = self.style.radius
        view.layer.cornerCurve = .continuous
        return view
    }()

    lazy var fgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = self.style.radius
        view.layer.cornerCurve = .continuous
        view.layer.isOpaque = false
        view.isOpaque = false
        return view
    }()

    // MARK: - Init

    public init() {
        super.init(frame: .zero)
        self.addSubview(self.bgView)
        self.addSubview(self.fgView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - User Interaction

    func animBorder(to value: CGFloat) {
        let anim = CABasicAnimation()
        anim.timingFunction = .init(name: .easeInEaseOut)
        anim.fromValue = self.bgView.layer.borderWidth
        anim.toValue = value
        anim.duration = 0.15
        self.bgView.layer.add(anim, forKey: "borderWidth")
        self.bgView.layer.borderWidth = value
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.style.borderWidthTouch)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.style.borderWidthDefault)
        self.presentColorPicker()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.style.borderWidthDefault)
    }

    // MARK: - Color Picker Popover

    func presentColorPicker() {
        if let vc = self.firstViewController() {
            let colorPicker = UIColorPickerViewController()
            colorPicker.title = "Background Color"
            colorPicker.supportsAlpha = self.showsAlpha
            colorPicker.delegate = self
            colorPicker.modalPresentationStyle = .popover
            colorPicker.selectedColor = self.color
            if let popover = colorPicker.popoverPresentationController {
                popover.sourceView = self
                popover.sourceRect = self.bounds
                popover.permittedArrowDirections = [.up, .down, .left, .right]
                // popover.delegate = self
            }
            vc.present(colorPicker, animated: true)
        }
    }

    // MARK: - Drawing

    public override func draw(_ rect: CGRect) {
        self.fgView.backgroundColor = self.color
        self.fgView.layer.compositingFilter = self.isDarkMode ? "exclusionBlendMode" : "multiplyBlendMode"
        self.bgView.backgroundColor = self.isDarkMode ? .black : .white
        self.bgView.layer.borderColor = self.style.borderColor.cgColor
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        self.style.size
    }

    public override func layoutSubviews() {
        self.bgView.frame = .init(origin: .zero, size: self.intrinsicContentSize)
        self.fgView.frame = .init(origin: .zero, size: self.intrinsicContentSize)
    }

    // MARK: - Helpers

    private func firstViewController() -> UIViewController? {
        var next = self.next
        while next != nil {
            if let vc = next as? UIViewController {
                return vc
            }
            next = next?.next
        }

        return nil
    }
}

// MARK: - UIColorPickerViewControllerDelegate

extension ColorPickerPlatformView: UIColorPickerViewControllerDelegate {
    public func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        guard !self.isLocked else { return }

        self.color = color

        if continuously {
            self.onEvent?(.didChange(.init(newValue: color)))
        } else {
            if self.commitedColor != color {
                self.onEvent?(.didChange(.init(newValue: color, oldValue: self.commitedColor, commit: true)))
                self.commitedColor = color
            }
        }
        self.setNeedsDisplay()
    }
}

#endif

extension ColorPickerPlatformView {
    public enum Event {
        case didChange(Change)

        public struct Change {
            public var newValue: PlatformColor
            public var oldValue: PlatformColor?
            public var commit: Bool

            public init(newValue: PlatformColor, oldValue: PlatformColor? = nil, commit: Bool = false) {
                self.newValue = newValue
                self.oldValue = oldValue
                self.commit = commit
            }

        }
    }
}

// MARK: - Style

extension ColorPickerPlatformView {
    struct Style: Sendable, Equatable {
        var size: CGSize
        var borderColor: DynamicColor
        var borderWidthDefault: CGFloat
        var borderWidthHover: CGFloat
        var borderWidthTouch: CGFloat
        var radius: CGFloat
        var lightBlendMode: String
        var darkBlendMode: String

        static var `default`: Style {
            .init(
                size: .init(width: 40, height: 25),
                borderColor: DynamicColor(light: .init(white: 0.8, alpha: 1), dark: .init(white: 0.32, alpha: 1)),
                borderWidthDefault: 2,
                borderWidthHover: 4,
                borderWidthTouch: 5,
                radius: 10,
                lightBlendMode: "multiplyBlendMode",
                darkBlendMode: "exclusionBlendMode"
            )
        }
    }
}

// MARK: - Previews

extension ColorPickerPlatformView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let picker = ColorPickerPlatformView()
            picker.color = .systemTeal
            picker.showsAlpha = true
            return picker
        }

        func updateView(_ view: ViewType, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        ColorPickerPlatformView.Preview()
    }
    .padding(80)
}
