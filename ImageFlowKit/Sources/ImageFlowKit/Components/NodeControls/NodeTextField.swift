//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

import Helpers
import Logging
import SwiftUI

#if os(macOS)
typealias NodeTextField = NodeTextFieldNSView
#endif

#if os(iOS)
typealias NodeTextField = NodeTextFieldUIView
#endif

protocol NodeTextFieldProtocol: PlatformView {
    var text: String { get set }
    var onEvent: ((NodeTextFieldEvent) -> ())? { get set }
    var borderColor: PlatformColor { get set }
    var nodeTextFieldFont: NodeTextFieldFont { get set }
}

enum NodeTextFieldEvent {
    case textDidChange(String)
    case sizeDidChange
    case drag(GesturePhase, CGFloat, CGFloat)
}

enum NodeTextFieldFont {
    case mono
    case system
}

extension NodeTextField {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeTextField {
            let view = NodeTextField("Hello!", borderColor: .systemBlue)
            view.onEvent = { event in
                log("event: \(event)")
            }
            return view
        }

        func updateView(_ view: NodeTextField, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeTextField, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeTextField.Preview()
            .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 500, minHeight: 500)
    .background(.white)
}
