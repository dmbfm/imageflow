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
    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: PlatformColor = .systemBlue

    public var valueDidChange: ((Value) -> ())?

    lazy var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.decimalSeparator = "."
        return f
    }()

    lazy var locale: Locale = { .init(identifier: "en-US") }()

    lazy var textField: NodeTextField = {
        let view = NodeTextField(self.value.float.formatted(.nodeNumber), borderColor: self.tint)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textDidChange = { [weak self] value in
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
        }
        return view
    }()

    init(_ value: Value) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.addSubview(self.textField)
        self.textField.constraintToFill(self)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.textField.intrinsicContentSize
    }

    func setValue(_ value: Double) {
        self.value.float = value
        self.valueDidChange?(self.value)
    }

    func update() {
        self.textField.text = self.value.float.formatted(.nodeNumber)
        self.invalidateIntrinsicContentSize()
    }
}

#if os(macOS)
extension NodeNumberInput: NSTextFieldDelegate {
}
#endif

extension NodeNumberInput {
    fileprivate struct Preview: PlatformViewRepresentable {

        @Binding var value: Value

        func makeView(context: Context) -> NodeNumberInput {
            let view = NodeNumberInput(self.value)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.valueDidChange = { value in
                self.value = value
            }
            return view
        }

        func updateView(_ view: NodeNumberInput, context: Context) {
            if self.value != view.value {
                view.value = self.value
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
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
        Text(formatted)
            .font(.caption2)
            .fontDesign(.monospaced)
    }
    .frame(minWidth: 500)
    .frame(height: 500)
    .background(.white)
}
