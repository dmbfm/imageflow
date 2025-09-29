import SwiftUI

#if canImport(AppKit)
import AppKit
typealias NodeTitleView = NodeTitleNSView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeTitleView = NodeTitleUIView
#endif

// MARK: - NodeTitleView Common

extension NodeTitleView {

    // MARK: - Public

    public struct ViewModel: Sendable, Equatable {
        var title: String = "Some node"
        var subtitle: String = "Node Type"
        var icon: String = "paintbrush"
        var color: DynamicColor = .blue

        public init() {}

        public init(title: String, subtitle: String, icon: String, color: DynamicColor) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.color = color
        }

        public init(_ node: FlowNode) {
            self.title = node.name
            self.subtitle = node.kind.displayName
            self.icon = node.kind.icon
            self.color = node.kind.frontendNodeColor
        }
    }

    // MARK: - Internal

    struct Style {
        var iconTitleSpacing: CGFloat = 10
        var titleSubtitleSpacing: CGFloat = 0
        var iconSize: CGFloat = 24
        var iconPointSize: CGFloat = 12
        var minTitleWidth: CGFloat = 80

        static var macOS: Self {
            .init(iconTitleSpacing: 4, iconPointSize: 16)
        }

        static var iOS: Self {
            .init(minTitleWidth: 200)
        }
    }
}

// MARK: - Previews

extension NodeTitleView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeTitleView {
            let view = NodeTitleView(.init())
            return view
        }

        func updateView(_ view: NodeTitleView, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeTitleView, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeTitleView.Preview()
            .border(.orange.opacity(0.1))
    }
    .padding()
    .background(.white)
}
