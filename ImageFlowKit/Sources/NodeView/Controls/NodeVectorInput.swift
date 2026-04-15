import Backend
import Helpers
import Logging
import SharedModels
import SwiftUI
import TextInput
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

extension NodeVectorInput {
    @MainActor
    class DelegateForNumberInput: NumberTextInputDelegate {
        weak var control: NodeVectorInput?
        var index: Int

        init(control: NodeVectorInput?, index: Int) {
            self.control = control
            self.index = index
        }

        func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
            guard let view = self.control else { return }

            view.setValue(
                newValue: view.value(settingIndex: self.index, to: change.newValue),
                oldValue: view.value(settingIndex: self.index, to: change.oldValue),
                registerUndo: change.commit
            )
        }

        func numberInputDragStarted(_ numberInput: NumberInputController) {
            self.control?.emit(.statusBarMessage(StatusBarMessage.dragFloat.rawValue))
        }

        func numberInputDragEnded(_ numberInput: NumberInputController) {
            self.control?.emit(.statusBarMessage(nil))
        }

        func numberInputKeyboardWillShow(
            _ numberInput: NumberInputController,
            windowVerticalOverlap: Double,
            animationDuration: Double
        ) {
            self.control?.emit(
                .keyboardWillShow(windowVerticalOverlap: windowVerticalOverlap, duration: animationDuration)
            )
        }
    }
}

final class NodeVectorInput: PlatformCommonView, NodeControl {
    var context: NodeControlContext = .init()
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

    var numberInputDelegates: [DelegateForNumberInput] = []

    lazy var textFields: [NumberInputController] = {
        (0..<dim).map({ idx in
            let controller = NumberInputController()
            controller.sizingMode = .fixedWidth(68)
            controller.dragConfiguration = .free(.init(fractionalDigits: 2))
            let delegate = DelegateForNumberInput(control: self, index: idx)
            self.numberInputDelegates.append(delegate)
            controller.delegate = delegate
            return controller
        })
    }()

    var dim: Int {
        switch self.value.type {
        case .vector2:
            2
        case .vector3:
            3
        case .vector4:
            4
        default:
            0
        }
    }

    var isEditable: Bool {
        get {
            self.textFields.contains(where: { $0.isEnabled })
        }

        set {
            self.textFields.forEach { view in
                view.isEnabled = newValue
            }
        }
    }

    private var valueAtDragStart: CGFloat = 0.0

    public init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textFields.forEach { view in
            view.isEnabled = isEditable
        }

        for v in self.textFields {
            self.addSubview(v.view)
        }
    }

    public required init?(coder: NSCoder) {
        nil
    }

    let spacing: CGFloat = 4

    override var intrinsicContentSize: CGSize {
        let size = self.textFields.reduce(
            CGSize.zero,
            { acc, controller in
                .init(
                    width: acc.width + controller.view.intrinsicContentSize.width,
                    height: max(controller.view.intrinsicContentSize.height, acc.height)
                )
            }
        )

        return size + .init(width: self.spacing * CGFloat(self.dim - 1), height: 0)
    }

    override func doLayout() {
        _ = self.textFields.reduce(
            0.0,
            { acc, controller in
                controller.view.frame.origin = .init(x: acc, y: 0)
                controller.view.frame.size = controller.view.intrinsicContentSize
                return controller.view.frame.maxX + self.spacing
            }
        )
    }

    func value(settingIndex idx: Int, to component: Double) -> Value {
        var value = self.value
        switch value.type {
        case .vector2:
            value.vector2[idx] = component
        case .vector3:
            value.vector3[idx] = component
        case .vector4:
            value.vector4[idx] = component
        default:
            fatalError("invalid type: \(self.value.type)")
        }

        return value
    }

    private func update() {
        for (idx, view) in self.textFields.enumerated() {
            view.value = self.value[idx]
        }
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }
}

extension Value {
    fileprivate subscript(_ idx: Int) -> Double {
        get {
            switch self.type {
            case .vector2: self.vector2[idx]
            case .vector3: self.vector3[idx]
            case .vector4: self.vector4[idx]
            default: fatalError()
            }
        }
        set {
            switch self.type {
            case .vector2: self.vector2[idx] = newValue
            case .vector3: self.vector3[idx] = newValue
            case .vector4: self.vector4[idx] = newValue
            default: fatalError()
            }
        }
    }
}

extension NodeVectorInput {
    struct Preview: PlatformViewRepresentable {
        let value: Value
        func makeView(context: Context) -> NodeVectorInput {
            let view = NodeVectorInput(self.value)
            view.onEvent = { event in log("event: \(event)") }
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
        NodeVectorInput.Preview(value: .vector4(.zero))
    }
    .padding(80)
}
