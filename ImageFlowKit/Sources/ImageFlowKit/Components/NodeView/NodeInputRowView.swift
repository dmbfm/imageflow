import Helpers
import Logging
import SwiftUI
import Values

#if canImport(AppKit)
import AppKit
typealias NodeInputRowView = NodeInputRowNSView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeInputRowView = NodeInputRowUIView
#endif

@MainActor
protocol NodeInputRowViewProtocol {
    var input: FlowNode.Input { get set }
    var drawPortAsConnected: Bool { get set }
    var onEvent: ((NodeInputRowView.Event) -> ())? { get set }
    init(_ input: FlowNode.Input)
}

extension NodeInputRowView {
    public enum Event {
        case sizeDidChange
        case valueDidChange(Value)
        case dragPort(PortView.DragData)
    }
}

extension NodeInputRowView {
    fileprivate struct Preview: PlatformViewRepresentable {
        var input: FlowNode.Input = .init(
            label: "Something",
            index: 0,
            value: .float(0.5),
            semantics: .default,
            connected: false
        )
        func makeView(context: Context) -> NodeInputRowView {
            let view = NodeInputRowView(
                self.input
            )
            view.onEvent = { log("event: \($0)") }
            return view
        }

        func updateView(_ view: NodeInputRowView, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))

        NodeInputRowView.Preview(
            input: .init(label: "Other", index: 1, value: .bool(true), semantics: .default, connected: true)
        )
        .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 400, minHeight: 400)
    .background(.white)
}
