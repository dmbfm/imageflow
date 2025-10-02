import Helpers
import Logging
import SwiftUI

#if canImport(AppKit)
import AppKit
typealias NodeOutputBlockView = NodeOutputBlockNSView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeOutputBlockView = NodeOutputBlockUIView
#endif

@MainActor
protocol NodeOutputBlockViewProtocol {
    var outputs: [FlowNode.Output] { get set }
    var rows: [NodeOutputRowView] { get }
    var onEvent: ((NodeOutputBlockView.Event) -> ())? { get set }
    init(_ outputs: [FlowNode.Output])
}

extension NodeOutputBlockView {
    public enum Event {
        case sizeDidChange
        case dragPort(Int, PortView.DragData)
    }
}

extension NodeOutputBlockView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = NodeOutputBlockView([
                .init(label: "First Output", index: 0, type: .float, connected: false),
                .init(label: "Second Output", index: 1, type: .float, connected: true),
            ])
            view.onEvent = { log("event: \($0)") }
            return view
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
        NodeOutputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 300, minHeight: 300)
    .background(.white)
}
