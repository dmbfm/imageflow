//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

import Design
import Helpers
import Logging
import SwiftUI
import XKit

// import struct Helpers.EdgeInsets
// import struct Helpers.ShadowStyle

#if os(macOS)
typealias NodeTextField = NodeTextFieldNSView
#endif

#if os(iOS)
typealias NodeTextField = NodeTextFieldUIView
#endif

protocol NodeTextFieldProtocol: XView {
    var text: String { get set }
    var progress: CGFloat? { get set }
    var onEvent: ((NodeTextFieldEvent) -> ())? { get set }
    var placeholder: String? { get set }
    init(_ text: String, placeholder: String?, isEditable: Bool, style: NodeTextFieldStyle)
}

enum NodeTextFieldEvent {
    case textDidChange(String)
    case sizeDidChange
    case drag(Drag)
    case keyboardWillShow(windowVerticalOverlap: CGFloat, duration: CGFloat)

    struct Drag {
        var phase: XGestureRecognizer.State
        var dx: CGFloat
        var dy: CGFloat
        var shiftDown: Bool
        var optionDown: Bool
        var commandDown: Bool
    }
}

struct NodeTextFieldStyle: Sendable, Equatable, With {
    var fontSize: CGFloat
    var fontDesign: FontDesign
    var textColor: XColor
    var innerCornerRadius: CGFloat
    var outerCornerRadius: CGFloat
    var textInsets: XEdgeInsets
    var backgroundInsets: XEdgeInsets
    var backgroundColor: XColor
    var backgroundColorNonEditable: XColor
    var borderColor: XColor
    var borderWidth: CGFloat
    var shadowStyle: XViewEx.Shadow
    var progressFillHeight: CGFloat
    var progressFillColor: DynamicColor

    enum FontDesign: Sendable, Hashable {
        case regular
        case monospaced
    }

    #if os(macOS)
    static let defaultTextColor: XColor = .textColor
    #else
    static let defaultTextColor: XColor = .label
    #endif

    static var `default`: Self {
        .init(
            fontSize: 14,
            fontDesign: .regular,
            textColor: defaultTextColor,
            innerCornerRadius: 8,
            outerCornerRadius: 10,
            textInsets: .init(top: 6, left: 6, bottom: 8, right: 8),
            backgroundInsets: .init(top: 2, left: 2, bottom: 2, right: 2),
            backgroundColor: Colors.numberInputBackground.platformColor,
            backgroundColorNonEditable: Colors.numberInputBackground.platformColor.withAlphaComponent(0.25),
            borderColor: Colors.numberInputBorder.platformColor,
            borderWidth: 2,
            shadowStyle: .init(color: .black, opacity: 0.6, offset: .init(width: 0, height: 2), radius: 4),
            // shadowStyle: .init(radius: 4.0, color: .black, opacity: 0.6, offset: CGSize(width: 0, height: 2)),
            // shadowStyle: .init(radius: 4.0, color: .black, opacity: 0.6, offset: CGSize(width: 0, height: 2)),
            progressFillHeight: 2,
            progressFillColor: .init(light: .init(white: 0.5, alpha: 0.5), dark: .init(white: 0.5, alpha: 0.5))
        )
    }
}

extension NodeTextField {
    fileprivate struct Preview: XViewRepresentable {

        @Binding var text: String
        let placeholder: String?

        func makeView(context: Context) -> NodeTextField {
            let view = NodeTextField(
                self.text,
                style: .default
                    .with(\.borderColor, .systemBlue)
            )
            view.placeholder = self.placeholder
            view.progress = 0.8
            view.onEvent = { event in
                log("event: \(event)")
                switch event {
                case .textDidChange(let text):
                    self.text = text
                default:
                    break
                }
            }
            return view
        }

        func updateView(_ view: NodeTextField, context: Context) {
            view.text = self.text
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeTextField, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {

    @Previewable @State var text1: String = "Hello!"
    @Previewable @State var text2: String = ""

    VStack {
        NodeTextField.Preview(text: $text1, placeholder: nil)
        Text("'\(text1)'")
            .font(.caption)
        NodeTextField.Preview(text: $text2, placeholder: "Insert text...")
        Text("'\(text2)'")
            .font(.caption)

    }
    .frame(minWidth: 500, minHeight: 500)
}
