import Backend
import Helpers
import Logging
import SwiftUI
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeStringInput: PlatformCommonView, NodeControl {
    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: PlatformColor = .systemBlue

    var isEditable: Bool {
        get {
            self.textField.isEditable
        }

        set {
            self.textField.isEditable = newValue
        }
    }

    var context: NodeControlContext = .init()

    lazy var textField: NodeTextField = {
        let view = NodeTextField(
            self.value.string,
            placeholder: "Insert text...",
            style: .default.with(\.borderColor, self.tint)
        )
        view.onEvent = { [weak self] event in
            switch event {
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
                self?.setNeedsLayout()
            case .textDidChange(let text):
                self?.setValue(newValue: .string(text), registerUndo: true)
            default:
                break
            }
        }
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

    override func doLayout() {
        self.textField.frame.origin = .zero
        self.textField.frame.size = self.textField.intrinsicContentSize

        Layout.align(views: [self.textField], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }

}

extension NodeStringInput {
    struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeStringInput {
            let view = NodeStringInput(.string("Hello, world!"))
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

#Preview {
    VStack {
        NodeStringInput.Preview()

        NodeView.Preview(node: .init(kind: .valueNode(.string)))
    }
    .padding(80)
}
