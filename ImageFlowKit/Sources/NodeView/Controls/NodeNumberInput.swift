import Backend
import Helpers
import Logging
import SharedModels
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

final class NodeNumberInput: XViewEx, NodeControl {
    public var onEvent: ((NodeControlEvent) -> ())?

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: XColor = .systemBlue

    var context: NodeControlContext = .init()

    var range: ClosedRange<Double>? = nil

    var progress: Double? {
        get {
            self.textField.progress
        }

        set {
            self.textField.progress = newValue
        }
    }

    var dragConfiguration: NumberInputController.DragConfiguration {
        if let range = self.range {
            return .range(.closed(.init(range: range, snap: nil, fractionalDigits: 2)))
        } else {
            return .free(.init(sensitivity: .init(), fractionalDigits: 2))
        }
    }

    lazy var textField: NumberInputController = {
        let controller = NumberInputController()
        controller.sizingMode = .fixedWidth(84)
        controller.style = .default
            .with(\.font, .systemFont(ofSize: 12))
        controller.value = self.value.float
        controller.dragConfiguration = self.dragConfiguration
        controller.delegate = self
        return controller
    }()

    var isEditable: Bool {
        get {
            self.textField.isEnabled
        }
        set {
            self.textField.isEnabled = newValue
        }
    }

    public init(_ value: Value, range: ClosedRange<Double>? = nil, isEditable: Bool = true) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textField.isEnabled = isEditable

        self.addSubview(self.textField.view)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        let result = self.textField.view.intrinsicContentSize
        return result
    }

    override func layout() {
        super.layout()

        self.textField.view.frame.origin = .zero
        self.textField.view.frame.size = self.textField.view.intrinsicContentSize
    }

    func update() {
        self.textField.value = self.value.float
        self.updateProgress()
    }

    func updateProgress(_ textField: NodeNumberTextField? = nil) {
        // let textField = textField ?? self.textField
        if let range = self.range {
            self.textField.progress = range.progress(self.value.float)
        } else {
            self.textField.progress = nil
        }
    }
}

extension NodeNumberInput: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        self.setValue(newValue: .float(change.newValue), oldValue: .float(change.oldValue), registerUndo: change.commit)
    }

    func numberInputDragStarted(_ numberInput: NumberInputController) {
        let message: String? =
            if self.range != nil {
                StatusBarMessage.dragFloatRange.rawValue
            } else {
                StatusBarMessage.dragFloat.rawValue
            }

        self.onEvent?(.statusBarMessage(message))
    }

    func numberInputDragEnded(_ numberInput: NumberInputController) {
        self.onEvent?(.statusBarMessage(nil))
    }

    func numberInputKeyboardWillShow(
        _ numberInput: NumberInputController,
        windowVerticalOverlap: Double,
        animationDuration: Double
    ) {
        self.emit(.keyboardWillShow(windowVerticalOverlap: windowVerticalOverlap, duration: animationDuration))
    }
}

extension NodeNumberInput {
    public struct Preview: XViewRepresentable {

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
