//
//  NodeColorPicker.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 02/11/25.
//

import Helpers
import Logging
import SwiftUI

// MARK: - AppKit

#if canImport(AppKit)
import AppKit

final class NodeColorPicker: NSView {
    
    // MARK: - Exposed Properties

    var color: NSColor = .red {
        didSet {
            self.needsDisplay = true
        }
    }

    var showsAlpha: Bool = true

    var colorDidChange: ((NSColor) -> ())?
    
    // MARK: - Private Properties
    
    private let style: Style = .default
    
    private var trackingArea: NSTrackingArea?
    
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

    init() {
        super.init(frame: .zero)

        self.wantsLayer = true

        self.addSubview(self.bgView)
        self.addSubview(self.fgView)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Drawing

    override var wantsUpdateLayer: Bool {
        true
    }
    
    override func updateLayer() {
        super.updateLayer()
        self.fgView.layer?.backgroundColor = self.color.cgColor
        self.fgView.layer?.compositingFilter = self.effectiveAppearance.isDarkMode ? self.style.darkBlendMode : self.style.lightBlendMode
        self.bgView.layer?.borderColor = self.style.borderColor.cgColor
        self.bgView.layer?.backgroundColor = self.effectiveAppearance.isDarkMode ? .black : .white
    }
   
    
    // MARK: - Layout

    override var isFlipped: Bool {
        true
    }

    override var intrinsicContentSize: NSSize {
        self.style.size
    }

    override func layout() {
        super.layout()
        self.bgView.frame = .init(origin: .zero, size: self.intrinsicContentSize)
        self.fgView.frame = .init(origin: .zero, size: self.intrinsicContentSize)
    }
    
    // MARK: - User Interaction
    
    override func updateTrackingAreas() {
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

    override func mouseEntered(with event: NSEvent) {
        self.animBorder(to: self.style.borderWidthHover)
    }

    override func mouseExited(with event: NSEvent) {
        self.animBorder(to: self.style.borderWidthDefault)
    }
    
    private var isMouseDown: Bool = true
    
    override func mouseDown(with event: NSEvent) {
        self.isMouseDown = true
        self.animBorder(to: 6, duration: 0.1)
    }
    
    override func mouseUp(with event: NSEvent) {
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
        let cp = NSColorPanel.shared
        cp.isContinuous = true
        cp.color = self.color
        cp.showsAlpha = self.showsAlpha
        cp.setTarget(self)
        cp.setAction(#selector(Self.colorPanelHandler(_:)))
        cp.makeKeyAndOrderFront(nil)
    }

    @objc
    func colorPanelHandler(_ panel: NSColorPanel) {
        if self.color != panel.color {
            self.color = panel.color
            self.needsDisplay = true
            self.colorDidChange?(self.color)
        }
    }
}
#endif

// MARK: - UIKit

#if canImport(UIKit)
import UIKit

final class NodeColorPicker: UIView {

    // MARK: - Exposed Properties

    /// The selected color
    var color: UIColor = .systemRed

    /// If true, the color picker can edit the color's alpha values
    var showsAlpha: Bool = true

    /// A closure that is called (continuously) whenever the selected color changes.
    var colorDidChange: ((UIColor) -> ())?

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

    init() {
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animBorder(to: self.style.borderWidthTouch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animBorder(to: self.style.borderWidthDefault)
        self.presentColorPicker()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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

    override func draw(_ rect: CGRect) {
        self.fgView.backgroundColor = self.color
        self.fgView.layer.compositingFilter = self.isDarkMode ? "exclusionBlendMode" : "multiplyBlendMode"
        self.bgView.backgroundColor = self.isDarkMode ? .black : .white
        self.bgView.layer.borderColor = self.style.borderColor.cgColor
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        self.style.size
    }

    override func layoutSubviews() {
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

extension NodeColorPicker: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        self.color = color
        self.colorDidChange?(color)
        self.setNeedsDisplay()
    }
}

//extension NodeColorPicker: UIPopoverPresentationControllerDelegate { }

#endif

// MARK: - Style

extension NodeColorPicker {
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
                borderColor: DynamicColor(light: .init(white: 0.8, alpha: 1), dark: .init(white: 0.32, alpha: 1)), borderWidthDefault: 2,
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

extension NodeColorPicker {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            //            let view = UIColorWell()
            //            return view
            let picker = NodeColorPicker()
            picker.color = .systemTeal
            picker.showsAlpha = true
            picker.colorDidChange = { color in
                log("Color: \(color)")
            }
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
        NodeColorPicker.Preview()
    }
    .padding(80)
}
