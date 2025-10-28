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

final class NodeBooleanInput: PlatformCommonView, NodeControl {

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var onEvent: ((NodeControlEvent) -> ())?

    public var tint: PlatformColor = .systemBlue {
        didSet {
            #if os(iOS)
            self.toggle.onTintColor = self.tint
            #endif
        }
    }

    #if os(macOS)
    lazy var toggle: NSSwitch = {
        let view = NSSwitch()
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
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.toggle.intrinsicContentSize
    }

    override func doLayout() {
        self.toggle.frame.origin = .zero
        self.toggle.frame.size = self.toggle.intrinsicContentSize
    }

    func setValue(_ value: Bool) {
        self.value = .bool(value)
        self.emit(.valueDidChange(self.value))
    }
}

extension NodeBooleanInput {
    public struct Preview: PlatformViewRepresentable {
        @Binding var value: Value
        public func makeView(context: Context) -> NodeBooleanInput {
            let view = NodeBooleanInput(self.value)
            view.tint = .systemOrange
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value):
                    self.value = value
                case .sizeDidChange:
                    break
                }
            }
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
