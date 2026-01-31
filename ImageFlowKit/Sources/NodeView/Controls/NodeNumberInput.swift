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

struct NodeNumberInputFormat: FormatStyle {
    func format(_ value: Double) -> String {
        value.formatted(
            .number
                .locale(.init(identifier: "en-US"))
                .precision(.significantDigits(2...100))
                .grouping(.never)
        )
    }
}

extension FormatStyle where Self == NodeNumberInputFormat {
    static var nodeNumber: NodeNumberInputFormat {
        .init()
    }
}

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

    lazy var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.decimalSeparator = "."
        return f
    }()

    lazy var locale: Locale = { .init(identifier: "en-US") }()

    lazy var textField: NodeTextField = {
        let view = NodeTextField(
            self.value.float.formatted(.nodeNumber),
            style: .default.with(\.borderColor, self.tint)
        )
        view.onEvent = { [weak self] event in
            switch event {
            case .textDidChange(let value):
                guard let self else { return }
                if let number = Double(value) {
                    self.setValue(number)
                } else {
                    if value == "" {
                        self.setValue(0.0)
                    } else {
                        self.update()
                    }
                }
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
            case let .drag(phase, dx, dy):
                self?.onDrag(phase, dx, dy)
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

    func setValue(_ value: Double) {
        self.value.float = value
        self.emit(.valueDidChange(self.value))
    }

    func update() {
        self.textField.text = self.value.float.formatted(.nodeNumber)
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    private var valueAtDragStart: CGFloat = 0.0

    func onDrag(_ phase: GesturePhase, _ dx: CGFloat, _ dy: CGFloat) {
        switch phase {
        case .began:
            self.valueAtDragStart = self.value.float
        default:
            break
        }

        let t = dx * 0.001
        let newValue = (self.valueAtDragStart + t).truncateTo(fractionalDigits: 2)
        self.setValue(newValue)
    }
}

#if os(macOS)
extension NodeNumberInput: NSTextFieldDelegate {
}
#endif

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
