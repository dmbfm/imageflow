import Backend
import CommonUtils
import Design
import Logging
import PlatformUtils
import SwiftUI
import Values

#if os(macOS)
import AppKit
import AppKitUtils
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

public final class NodeNumberInput: PlatformView, NodeControl {
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
        let view = NodeTextField(self.value.float.formatted(.nodeNumber), borderColor: self.tint)
        view.translatesAutoresizingMaskIntoConstraints = false
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
            }
        }
        return view
    }()

    public init(_ value: Value) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.addSubview(self.textField)

        NSLayoutConstraint.activate([
            self.textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.textField.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        let result = self.textField.intrinsicContentSize
        return result
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
    
    @objc
    func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.valueAtDragStart = self.value.float
        default:
            break
        }
        
        let t = gesture.translation(in: nil).x * 0.001
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
        
        public init(value: Binding<Value>) {
            self._value = value
        }

        public func makeView(context: Context) -> NodeNumberInput {
            let view = NodeNumberInput(self.value)
            view.translatesAutoresizingMaskIntoConstraints = false
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
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .float(0.1234)
    var formatted: String {
        value.float.formatted(.nodeNumber)
    }
    VStack {
        NodeNumberInput.Preview(value: $value)
            .border(.gray.opacity(0.2))
        Text(formatted)
            .font(.caption2)
            .fontDesign(.monospaced)
    }
    .frame(minWidth: 500)
    .frame(height: 500)
    .background(.white)
}
