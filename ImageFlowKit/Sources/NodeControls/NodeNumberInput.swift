import Backend
import CommonUtils
import Design
import PlatformUtils
import SwiftUI
import Values
import Logging

#if os(macOS)
import AppKit
import AppKitUtils
#endif

#if os(iOS)
import UIKit
#endif

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
    
    lazy var locale: Locale = {.init(identifier: "en-US")}()
   
    lazy var textField: NodeTextField = {
        let view = NodeTextField(text: self.formattedValue, borderColor: self.tint)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textDidChange = { [weak self] value in
            guard let self else { return }
            if let number = Double(value) {
                self.value.float = number
                log("value: \(self.value)")
                self.invalidateIntrinsicContentSize()
            } else {
                self.update()
            }
        }
        return view
    }()
    
    init(_ value: Value) {
        self.value = value

        super.init(frame: .zero)
        
        self.addSubview(self.textField)
        self.textField.constraintToFill(self)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.textField.intrinsicContentSize
    }
    
    var formattedValue: String {
        self.value.float.formatted(.number.locale(self.locale).precision(.significantDigits(2...100)))
    }

    func update() {
        self.textField.text = self.formattedValue
    }
}

#if os(macOS)
extension NodeNumberInput: NSTextFieldDelegate {
}
#endif

extension NodeNumberInput {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = NodeNumberInput(.float(0.5))
            view.translatesAutoresizingMaskIntoConstraints = false
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
        NodeNumberInput.Preview()
    }
    .padding(100)
    .background(.white)
}
