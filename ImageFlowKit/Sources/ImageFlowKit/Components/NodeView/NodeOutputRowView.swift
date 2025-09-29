//
//  NodeInputRowView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 03/08/25.
//

import Helpers
import SwiftUI

#if canImport(AppKit)
import AppKit
typealias NodeOutputRowView = NodeOutputRowNSView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeOutputRowView = NodeOutputRowUIView
#endif

@MainActor
protocol NodeOutputRowViewProtocol {
    var output: FlowNode.Output { get set }
    var portView: PortView { get }
    var drawPortAsConnected: Bool { get set }
    var onEvent: ((NodeOutputRowView.Event) -> ())? { get set }
}

extension NodeOutputRowView {
    public enum Event {
        case sizeDidChange
        case dragPort(PortView.DragData)
    }
}

extension NodeOutputRowView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            NodeOutputRowView(.init(label: "Something", index: 0, type: .float, connected: false))
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
        NodeOutputRowView.Preview()
            .border(.gray.opacity(0.2))
        // .border(.red)
    }
    .padding(50)
    .background(.white)
}
