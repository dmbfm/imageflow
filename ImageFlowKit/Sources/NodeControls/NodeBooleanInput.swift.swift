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

public final class NodeBooleanInput: PlatformView, NodeControl {

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var valueDidChange: ((Value) -> ())?

    public var tint: PlatformColor = .systemBlue {
        didSet {
            #if os(macOS)
            self.toggle.contentTintColor = self.tint
            #else
            self.toggle.onTintColor = self.tint
            #endif
        }
    }

    #if os(macOS)
    lazy var toggle: NSButton = {
        let view = NSButton(checkboxWithTitle: "", target: self, action: #selector(Self.onToggleChange))
        view.contentTintColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.focusRingType = .exterior
        view.state = self.value.bool ? .on : .off
        return view
    }()
    
    func update() {
        self.toggle.state = self.value.bool ? .on : .off
    }
    
    @objc
    func onToggleChange() {
        self.setValue(self.toggle.state == .on)
    }
    
    #endif
    
    #if os(iOS)
    lazy var toggle: UISwitch = {
        let view = UISwitch()
        view.isOn = self.value.bool
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(Self.onToggleChange), for: .valueChanged)
        return view
    }()
    
    func update() {
        self.toggle.isOn = self.value.bool
    }
 
    @objc
    func onToggleChange() {
        self.setValue(self.toggle.isOn)
    }
    #endif
    
    public init(_ value: Value) {
        self.value = value

        super.init(frame: .zero)

        self.addSubview(self.toggle)
        self.toggle.constraintToFill(self)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.toggle.intrinsicContentSize
    }
    
    func setValue(_ value: Bool) {
        self.value = .bool(value)
        self.valueDidChange?(self.value)
    }
}

extension NodeBooleanInput {
    public struct Preview: PlatformViewRepresentable {
        @Binding var value: Value
        public func makeView(context: Context) -> NodeBooleanInput {
            let view = NodeBooleanInput(self.value)
            view.tint = .systemOrange
            view.valueDidChange = { value in self.value = value }
            return view
        }

        public func updateView(_ view: NodeBooleanInput, context: Context) {
            if view.value != self.value {
                view.value = self.value
            }
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .bool(false)
    VStack {
        NodeBooleanInput.Preview(value: $value)
            .border(.gray.opacity(0.2))
        Text("<\(value)>")
        Toggle("", isOn: .init(get: {
            value.bool
        }, set: { newValue in
            value = .bool(newValue)
        }))
    }
    .frame(width: 500, height: 500)
    .background(.white)
}
