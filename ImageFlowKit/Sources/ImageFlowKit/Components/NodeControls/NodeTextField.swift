//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

import Helpers
import Logging
import SwiftUI

import struct Helpers.EdgeInsets
import struct Helpers.ShadowStyle

#if os(macOS)
typealias NodeTextField = NodeTextFieldNSView
#endif

#if os(iOS)
typealias NodeTextField = NodeTextFieldUIView
#endif

protocol NodeTextFieldProtocol: PlatformView {
    var text: String { get set }
    var onEvent: ((NodeTextFieldEvent) -> ())? { get set }
    var placeholder: String? { get set }
    init(_ text: String, placeholder: String?, style: NodeTextFieldStyle)
}

enum NodeTextFieldEvent {
    case textDidChange(String)
    case sizeDidChange
    case drag(GesturePhase, CGFloat, CGFloat)
}

struct NodeTextFieldStyle: Sendable, Hashable, With {
    var fontSize: CGFloat
    var fontDesign: FontDesign
    var textColor: PlatformColor
    var innerCornerRadius: CGFloat
    var outerCornerRadius: CGFloat
    var textInsets: EdgeInsets
    var backgroundInsets: EdgeInsets
    var backgroundColor: PlatformColor
    var borderColor: PlatformColor
    var borderWidth: CGFloat
    var shadowStyle: ShadowStyle

    enum FontDesign: Sendable, Hashable {
        case regular
        case monospaced
    }

    #if os(macOS)
    static let defaultTextColor: PlatformColor = .textColor
    #else
    static let defaultTextColor: PlatformColor = .label
    #endif

    static var `default`: Self {
        .init(
            fontSize: 14,
            fontDesign: .regular,
            textColor: defaultTextColor,
            innerCornerRadius: 8,
            outerCornerRadius: 10,
            textInsets: .init(top: 6, bottom: 8, left: 6, right: 8),
            backgroundInsets: .init(top: 2, bottom: 2, left: 2, right: 2),
            backgroundColor: Colors.numberInputBackground.platformColor,
            borderColor: Colors.numberInputBorder.platformColor,
            borderWidth: 2,
            shadowStyle: .init(radius: 4, color: .black, opacity: 0.6, offset: .init(width: 0, height: 2))
        )
    }
}

extension NodeTextField {
    fileprivate struct Preview: PlatformViewRepresentable {
        
        @Binding var text: String
        let placeholder: String?
        
        func makeView(context: Context) -> NodeTextField {
            let view = NodeTextField(self.text, style: .default.with(\.borderColor, .systemBlue))
            view.placeholder = self.placeholder
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
    .background(.white)
}
