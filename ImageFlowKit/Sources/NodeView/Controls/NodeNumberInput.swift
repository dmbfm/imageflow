import Backend
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeNumberInput: PlatformCommonView, NodeControl {
    public var onEvent: ((NodeControlEvent) -> ())?

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: PlatformColor = .systemBlue

    var context: NodeControlContext = .init()

    lazy var textField: NodeNumberTextField = {
        let view = NodeNumberTextField(
            self.value.float,
            isEditable: true
        )
        view.onEvent = { [weak self] event in
            switch event {
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
            case .valueDidChange(let change):
                self?.setValue(
                    newValue: .float(change.newValue),
                    oldValue: change.oldValue.map({ .float($0) }),
                    registerUndo: change.commit
                )
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self?.emit(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
            case .dragStateChanged(let dragState):
                switch dragState {
                case .dragging:
                    self?.onEvent?(.statusBarMessage(StatusBarMessage.dragFloat.rawValue))
                case .notDragging:
                    self?.onEvent?(.statusBarMessage(nil))
                }
                break
            }
        }
        return view
    }()

    var isEditable: Bool {
        get {
            self.textField.isEditable
        }
        set {
            self.textField.isEditable = newValue
        }
    }

    public init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textField.isEditable = isEditable

        self.addSubview(self.textField)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        let result = self.textField.intrinsicContentSize
        return result
    }

    override func doLayout() {
        self.textField.frame.origin = .zero
        self.textField.frame.size = self.textField.intrinsicContentSize
    }

    func update() {
        self.textField.value = self.value.float
    }
}

extension NodeNumberInput {
    public struct Preview: PlatformViewRepresentable {

        @Binding var value: Value
        var isEditable: Bool = true

        public init(value: Binding<Value>, isEditable: Bool = true) {
            self._value = value
            self.isEditable = isEditable
        }

        public func makeView(context: Context) -> NodeNumberInput {
            let view = NodeNumberInput(self.value, isEditable: self.isEditable)
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value): self.value = value
                case .sizeDidChange: break
                case .keyboardWillShow: break
                case .statusBarMessage(_): break
                }
            }
            return view
        }

        public func updateView(_ view: NodeNumberInput, context: Context) {
            if self.value != view.value {
                view.value = self.value
            }

            view.isEditable = self.isEditable
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .float(0.1234)
    @Previewable @State var isEditable: Bool = true
    var formatted: String {
        value.float.formatted(.nodeNumber)
    }
    VStack {
        NodeNumberInput.Preview(value: $value, isEditable: isEditable)
            .border(.gray.opacity(0.2))
        Text(formatted)
            .font(.caption2)
            .fontDesign(.monospaced)
        Toggle(
            isOn: $isEditable,
            label: {
                Text("Editable")
            }
        )
        .frame(width: 200)
    }
    .frame(minWidth: 500)
    .frame(height: 500)
    .background(.white)
}
