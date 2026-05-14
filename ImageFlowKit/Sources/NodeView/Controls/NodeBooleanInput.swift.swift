import Backend
import Helpers
import SwiftUI
import Values
import XKit

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeBooleanInput: XViewEx, NodeControl {
    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var onEvent: ((NodeControlEvent) -> ())?

    var tint: XColor = .systemBlue {
        didSet {
            #if os(iOS)
            self.toggle.onTintColor = self.tint
            #endif
        }
    }

    var isEditable: Bool {
        get {
            self.toggle.isEnabled
        }

        set {
            self.toggle.isEnabled = newValue
        }
    }

    var context: NodeControlContext = .init()

    #if os(macOS)
    lazy var toggle: NSSwitch = {
        let view = NSSwitch()
        view.focusRingType = .exterior
        view.state = self.value.bool ? .on : .off
        view.target = self
        view.action = #selector(Self.onToggleChange)
        return view
    }()

    func update() {
        self.toggle.state = self.value.bool ? .on : .off
    }

    @objc
    func onToggleChange() {
        self.setValue(newValue: .bool(self.toggle.state == .on), registerUndo: true)
    }

    #endif

    #if os(iOS)
    lazy var toggle: UISwitch = {
        let view = UISwitch()
        view.isOn = self.value.bool
        view.addTarget(self, action: #selector(Self.onToggleChange), for: .valueChanged)
        return view
    }()

    func update() {
        self.toggle.isOn = self.value.bool
    }

    @objc
    func onToggleChange() {
        self.setValue(newValue: .bool(self.toggle.isOn), registerUndo: true)
    }
    #endif

    init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.toggle.isEnabled = self.isEditable

        self.addSubview(self.toggle)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        self.toggle.intrinsicContentSize
    }

    override func layout() {
        super.layout()
        self.toggle.frame.origin = .zero
        self.toggle.frame.size = self.toggle.intrinsicContentSize
    }
}

extension NodeBooleanInput {
    struct Preview: XViewRepresentable {
        @Binding var value: Value
        func makeView(context: Context) -> NodeBooleanInput {
            let view = NodeBooleanInput(self.value)
            view.tint = .systemOrange
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value):
                    self.value = value
                case .sizeDidChange:
                    break
                case .keyboardWillShow:
                    break
                case .statusBarMessage:
                    break
                }
            }
            return view
        }

        func updateView(_ view: NodeBooleanInput, context: Context) {
            if view.value != self.value {
                view.value = self.value
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .bool(false)
    var desc: String {
        value.bool.description
    }
    VStack {
        NodeBooleanInput.Preview(value: $value)
            .border(.gray.opacity(0.2))
        Text(desc)
        Toggle(
            "",
            isOn: .init(
                get: {
                    value.bool
                },
                set: { newValue in
                    value = .bool(newValue)
                }
            )
        )
    }
    .frame(width: 500, height: 500)
    .background(.white)
}
