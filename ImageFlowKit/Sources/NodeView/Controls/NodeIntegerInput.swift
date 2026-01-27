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

final class NodeIntegerInput: PlatformCommonView, NodeControl {
    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: PlatformColor = .systemBlue

    private var style: Style = .default

    lazy var textField: NodeTextField = {
        let view = NodeTextField(
            self.value.int.formatted(.nodeInterger),
            style: .default.with(\.borderColor, self.tint)
        )
        view.onEvent = { [weak self] event in
            switch event {
            case .textDidChange(let value):
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
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
            case .drag:
                // NOTE: We don't use dragging for integer inputs currently
                break
            }
        }
        return view
    }()

    #if os(macOS)
    lazy var stepper: NSStepper = {
        let view = NSStepper()
        view.value = Double(self.value.int)
        view.minValue = -.infinity
        view.maxValue = .infinity
        view.increment = 1
        view.autorepeat = true
        view.isContinuous = true
        view.target = self
        view.action = #selector(Self.stepperHandler)
        return view
    }()
    #endif

    #if os(iOS)
    lazy var stepper: UIStepper = {
        let view = UIStepper()
        view.value = Double(self.value.int)
        view.minimumValue = -.infinity
        view.maximumValue = .infinity
        view.stepValue = 1
        view.autorepeat = true
        view.isContinuous = true
        view.addTarget(self, action: #selector(Self.stepperHandler), for: .valueChanged)
        return view
    }()

    #endif

    @objc func stepperHandler() {
        self.value = .int(Int(self.stepper.value))
        self.emit(.valueDidChange(self.value))
    }

    var isEditable: Bool {
        get {
            self.textField.isEditable
        }

        set {
            self.textField.isEditable = newValue
            self.stepper.isHidden = !newValue
        }
    }

    init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textField.isEditable = isEditable
        self.stepper.isHidden = !isEditable

        self.addSubview(self.textField)
        self.addSubview(self.stepper)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.textField.intrinsicContentSize.minMax(self.stepper.intrinsicContentSize, width: .sum, height: .max)
            + .init(width: self.style.textFieldStepperPadding, height: 0)
    }

    override func doLayout() {
        self.textField.frame.origin = .zero
        self.textField.frame.size = self.textField.intrinsicContentSize
        self.stepper.frame.origin = .init(x: self.textField.frame.maxX + self.style.textFieldStepperPadding, y: 0)
        self.stepper.frame.size = self.stepper.intrinsicContentSize

        Layout.align(
            views: [
                self.textField,
                self.stepper,
            ],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }

    func setValue(_ value: Int) {
        self.value.int = value
        self.emit(.valueDidChange(self.value))
    }

    func update() {
        self.textField.text = self.value.int.formatted(.nodeInterger)
        self.stepper.value = Double(self.value.int)
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }
}

#if os(macOS)
extension NSStepper {
    var value: Double {
        get {
            self.doubleValue
        }
        set {
            self.doubleValue = newValue
        }
    }
}
#endif

extension NodeIntegerInput {
    struct Style: Sendable, Equatable, With {
        var textFieldStepperPadding: CGFloat

        static var iOS: Self {
            .init(textFieldStepperPadding: 4)
        }

        static var macOS: Self {
            Self.iOS.with(\.textFieldStepperPadding, 4)
        }

        static var `default`: Self {
            #if os(macOS)
            .macOS
            #else
            .iOS
            #endif
        }
    }

}

extension NodeIntegerInput {
    fileprivate struct Preview: PlatformViewRepresentable {

        @Binding var value: Value

        func makeView(context: Context) -> NodeIntegerInput {
            let view = NodeIntegerInput(self.value)
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value): self.value = value
                case .sizeDidChange: break
                }
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
        Text("\(value.description)")
            .font(.caption2)
            .fontDesign(.monospaced)

        NodeView.Preview(node: .init(kind: .valueNode(.int)))

    }
    .frame(minWidth: 500)
    .frame(minHeight: 500)
    .background(.white)
}
