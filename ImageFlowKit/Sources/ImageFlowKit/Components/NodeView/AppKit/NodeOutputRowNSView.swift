//
//
//  NodeOutputRowUIView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

// #if canImport(AppKit)

// import AppKit
// import Helpers

// final class NodeOutputRowNSView: NSView, NodeOutputRowViewProtocol {

//     public var output: FlowNode.Output {
//         didSet {
//             if self.output != oldValue {
//                 self.update()
//             }
//         }
//     }

//     public var drawPortAsConnected: Bool = false {
//         didSet {
//             self.portView.connected = self.drawPortAsConnected || self.output.connected
//         }
//     }

//     public var onEvent: ((Event) -> ())?

//     var portView: PortView
//     var labelView: NSTextField

//     private static let labelSafetyMargin: CGFloat = 2.0

//     var labelSize: CGSize {
//         self.labelView.intrinsicContentSize + .init(width: Self.labelSafetyMargin, height: 0)
//     }

//     var portSize: CGFloat {
//         Design.default.portSize
//     }

//     init(_ output: FlowNode.Output) {
//         self.output = output
//         self.portView = .init(connected: output.connected)
//         self.labelView = .init(nodeRowLabelWithString: output.label)

//         super.init(frame: .zero)

//         self.portView.onEvent = { [weak self] event in
//             switch event {
//             case .drag(let data):
//                 self?.onEvent?(.dragPort(data))
//             }
//         }

//         self.addSubview(self.portView)
//         self.addSubview(self.labelView)
//     }

//     required init?(coder: NSCoder) {
//         nil
//     }

//     func update() {
//         self.portView.connected = self.drawPortAsConnected || self.output.connected
//         if self.output.label != self.labelView.stringValue {
//             self.labelView.stringValue = self.output.label
//             self.onEvent?(.sizeDidChange)
//         }
//     }

//     override var isFlipped: Bool {
//         true
//     }

//     override var intrinsicContentSize: NSSize {
//         let width = portSize + Design.default.portLabelSpacing + labelSize.width
//         let height = Design.default.nodeRowHeight
//         return .init(width: width, height: height)
//     }

//     override func layout() {
//         self.portView.frame = .init(
//             x: self.bounds.width - self.portSize,
//             y: 0,
//             width: self.portSize,
//             height: self.portSize
//         )
//         self.labelView.frame = .init(
//             x: self.portView.frame.minX - self.labelSize.width - Design.default.portLabelSpacing,
//             y: 0,
//             width: self.labelSize.width,
//             height: self.labelSize.height
//         )
//         Layout.align(
//             views: [self.portView, self.labelView],
//             alignment: .verticalCenter,
//             guide: .constant(self.bounds.midY)
//         )
//     }

// }

// #endif
