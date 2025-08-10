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

struct NodeIntegerInputFormat: FormatStyle {
    func format(_ value: Int) -> String {
        value.formatted(.number.grouping(.never))
    }
}

extension FormatStyle where Self == NodeIntegerInputFormat {
    static var nodeInterger: NodeIntegerInputFormat {
        .init()
    }
}

public final class NodeIntegerInput: PlatformView, NodeControl {
    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: PlatformColor = .systemBlue

    public var valueDidChange: ((Value) -> ())?
    
    lazy var textField: NodeTextField = {
        let view = NodeTextField(self.value.int.formatted(.nodeInterger), borderColor: self.tint)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textDidChange = { [weak self] value in
            guard let self else { return }
            if let number = Int(value) {
                self.setValue(number)
            } else {
                if value == "" {
                    self.setValue(0)
                } else {
                    self.update()
                }
            }
        }
        view.sizeDidChange = { [weak self] in
            self?.invalidateIntrinsicContentSize()
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
    
    func setValue(_ value: Int) {
        self.value.int = value
        self.valueDidChange?(self.value)
    }

    func update() {
        self.textField.text = self.value.int.formatted(.nodeInterger)
        self.invalidateIntrinsicContentSize()
    }
}

#if os(macOS)
extension NodeIntegerInput: NSTextFieldDelegate {
}
#endif

extension NodeIntegerInput {
    fileprivate struct Preview: PlatformViewRepresentable {
        
        @Binding var value: Value
        
        func makeView(context: Context) -> NodeIntegerInput {
            let view = NodeIntegerInput(self.value)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.valueDidChange = { value in
                self.value = value
            }
            return view
        }

        func updateView(_ view: NodeIntegerInput, context: Context) {
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
    @Previewable @State var value: Value = .int(1234)
    VStack {
        NodeIntegerInput.Preview(value: $value)
        Text("\(value)")
            .font(.caption2)
            .fontDesign(.monospaced)
    }
    .frame(minWidth: 500)
    .frame(height: 500)
    .background(.white)
}
