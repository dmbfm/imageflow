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
    public var sizeDidChange: (() -> ())?

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
        view.sizeDidChange = { [weak self] in
            self?.invalidateIntrinsicContentSize()
            self?.superview?.invalidateIntrinsicContentSize()
            self?.sizeDidChange?()
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
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        let result = self.textField.intrinsicContentSize
        print("size: \(result)")
        return result
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
            .border(.gray.opacity(0.2))
        Text(formatted)
            .font(.caption2)
            .fontDesign(.monospaced)
    }
    .frame(minWidth: 500)
    .frame(height: 500)
    .background(.white)
}
