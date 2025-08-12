import CommonUtils
import Models
import PlatformUtils
import SwiftUI
import Values

#if canImport(AppKit)
import AppKit
typealias NodeInputBlockView = NodeInputBlockNSView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeInputBlockView = NodeInputBlockUIView
#endif

extension NodeInputBlockView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeInputBlockView {
            let view = NodeInputBlockView([
                .init(label: "Some number", index: 0, value: .float(0.5), semantics: .default, connected: false),
                .init(label: "Other", index: 0, value: .float(0.1234), semantics: .default, connected: false),
                .init(label: "Other", index: 0, value: .float(0.1234), semantics: .default, connected: false),
            ])
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
        NodeInputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .padding(200)
}
