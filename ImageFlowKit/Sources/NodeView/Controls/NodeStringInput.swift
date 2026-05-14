import Backend
import Helpers
import SwiftUI
import TextInput
import Values
import XKit

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeStringInput: XViewEx, NodeControl {
    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: XColor = .systemBlue

    var isEditable: Bool {
        get {
            self.textField.isEnabled
        }

        set {
            self.textField.isEnabled = newValue
        }
    }

    var context: NodeControlContext = .init()

    lazy var textField: TextInput = {
        let view = TextInput(behaviours: [
            .cancelAbort,
            .cancelBecomeNotEditable,
            .submitBecomeNotEditable,
            .clickBecomeEditableAndFocus,
        ])
        view.placeholder = "Insert text..."
        view.delegate = self
        view.sizingMode = .textWidth
        return view
    }()

    init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.textField.isEditable = isEditable

        self.addSubview(self.textField)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func update() {
        if self.textField.text != self.value.string {
            self.textField.text = self.value.string
        }
    }

    override var intrinsicContentSize: CGSize {
        self.textField.intrinsicContentSize
    }

    override func layout() {
        super.layout()

        self.textField.frame.origin = .zero
        self.textField.frame.size = self.textField.intrinsicContentSize

        Layout.align(views: [self.textField], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }

}

extension NodeStringInput: TextInputDelegate {
    func textInputDidChange(_ textInput: TextInput) {
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
        self.setNeedsLayout()
    }

    func textInputDidEndEditing(_ textInput: TextInput) {
        self.setValue(newValue: .string(textInput.text), oldValue: nil, registerUndo: true)
    }

    func textInputDidCancel(_ textInput: TextInput) {
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
        self.setNeedsLayout()
    }

    func textInputKeyboardWillShow(_ textInput: TextInput, windowVerticalOverlap: Double, animationDuration: Double) {
        self.emit(.keyboardWillShow(windowVerticalOverlap: windowVerticalOverlap, duration: animationDuration))
    }
}

extension NodeStringInput {
    struct Preview: XViewRepresentable {
        func makeView(context: Context) -> NodeStringInput {
            let view = NodeStringInput(.string("Hello, world!"))
            view.onEvent = { _ in }
            return view
        }

        func updateView(_ view: ViewType, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeStringInput.Preview()

        NodeView.Preview(node: .init(kind: .valueNode(.string)))
    }
    .padding(80)
}
