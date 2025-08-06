//
//  NodeViewAppKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 05/08/25.
//

import CanvasView
import EventEmitter
import Models
import PlatformUtils
import SwiftUI

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

public final class NodeView: PlatformView, CanvasNodeView {

    // MARK: - Public Properties

    public var node: FlowNode {
        didSet {

        }
    }

    public var id: UUID {
        self.node.id
    }

    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()

    // MARK: - Public Types

    public enum Event {

    }

    // MARK: - Common

    var titleModel: NodeTitleView.Model {
        .init(
            title: self.node.name,
            subtitle: self.node.kind.displayName,
            icon: self.node.kind.icon,
            color: self.node.kind.frontendNodeColor,  //.systemBlue
        )
    }

    struct Style {
        var titlePadding: EdgeInsets = .init(top: 18, leading: 8, bottom: 18, trailing: 8)
        var bottomPadding: CGFloat = 8
    }

    var style = Style()

    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView()
        view.color = self.node.kind.frontendNodeColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleView: NodeTitleView = {
        let view = NodeTitleView(self.titleModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.border(.red)
        return view
    }()

    lazy var titleContainerView: PlatformView = {
        let view = PlatformView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.titleView)
        NSLayoutConstraint.activate([
            self.titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.style.titlePadding.top),
            self.titleView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: self.style.titlePadding.leading
            ),
            self.titleView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -self.style.titlePadding.trailing
            ),
        ])

        view.heightAnchor.constraint(
            equalToConstant: self.titleView.intrinsicContentSize.height + self.style.titlePadding.top
                + self.style.titlePadding.bottom
        ).isActive = true
        return view
    }()

    lazy var inputBlockView: NodeInputBlockView = {
        let view = NodeInputBlockView()
        view.translatesAutoresizingMaskIntoConstraints = false

        for input in self.node.inputs {
            view.addRow(.init(input))
        }

        return view
    }()

    lazy var outputBlockView: NodeOutputBlockView = {
        let view = NodeOutputBlockView()
        view.translatesAutoresizingMaskIntoConstraints = false

        for output in self.node.outputs {
            view.addRow(.init(output))
        }

        return view
    }()

    #if os(macOS)
    lazy var stackView: NSStackView = {
        let view = NSStackView()
        // view.border(.red)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .vertical
        view.alignment = .leading
        view.spacing = 0
        view.addArrangedSubview(self.titleContainerView)
        view.addArrangedSubview(self.inputBlockView)
        view.addArrangedSubview(self.outputBlockView)
        return view
    }()
    #else
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 0
        view.addArrangedSubview(self.titleContainerView)
        view.addArrangedSubview(self.inputBlockView)
        view.addArrangedSubview(self.outputBlockView)
        return view
    }()
    #endif

    init(_ node: FlowNode) {
        self.node = node

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.backgroundView.constraintToFill(self)

        self.addSubview(self.stackView)
        self.stackView.constraintToFill(self)

        self.invalidateIntrinsicContentSize()
        let size = self.intrinsicContentSize
        self.inputBlockView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.outputBlockView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        self.titleContainerView.widthAnchor.constraint(equalToConstant: size.width).isActive = true

        #if os(macOS)
        self.shadow = .init()
        self.wantsLayer = true
        self.layer?.shadowRadius = 4
        self.layer?.shadowColor = .black
        #else
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = .zero
        #endif
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        let titleSize = self.titleView.intrinsicContentSize
        let inputBlockSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize = self.outputBlockView.intrinsicContentSize
        let width = max(
            self.style.titlePadding.leading + titleSize.width + self.style.titlePadding.trailing,
            inputBlockSize.width,
            outputBlockSize.width
        )
        let height =
            self.style.titlePadding.top + titleSize.height + self.style.titlePadding.bottom + inputBlockSize.height
            + outputBlockSize.height + self.style.bottomPadding
        return CGSize(width: width, height: height)
    }
}
