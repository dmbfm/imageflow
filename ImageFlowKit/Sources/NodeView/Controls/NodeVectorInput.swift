import Backend
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

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

    lazy var textFields: [NodeTextField] = {
        (0..<dim).map { idx in
            let view = NodeTextField(
                self.value[idx].formatted(.nodeNumber),
                style: .default.with(\.borderColor, self.tint)
            )
            view.onEvent = { [weak self] event in
                switch event {
                case .textDidChange(let value):
                    guard let self else { return }
                    if let number = Double(value) {
                        self.setValue(newValue: self.value(settingIndex: idx, to: number), registerUndo: true)
                    } else {
                        if value == "" {
                            self.setValue(newValue: self.value(settingIndex: idx, to: 0.0), registerUndo: true)
                        } else {
                            self.update()
                        }
                    }
                case .sizeDidChange:
                    self?.invalidateIntrinsicContentSize()
                    self?.emit(.sizeDidChange)
                case let .drag(drag):
                    self?.onDrag(idx, drag)
                case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                    self?.emit(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
                }
            }
            return view
        }
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
            self.textFields.contains(where: { $0.isEditable })
        }

        set {
            self.textFields.forEach { view in
                view.isEditable = newValue
            }
        }
    }

    private var valueAtDragStart: CGFloat = 0.0

    public init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textFields.forEach { view in
            view.isEditable = isEditable
        }

        for v in self.textFields {
            self.addSubview(v)
        }
    }

    public required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        self.textFields.reduce(
            CGSize.zero,
            { acc, view in
                .init(
                    width: acc.width + view.intrinsicContentSize.width,
                    height: max(view.intrinsicContentSize.height, acc.height)
                )
            }
        )
    }

    override func doLayout() {
        _ = self.textFields.reduce(
            0.0,
            { acc, view in
                view.frame.origin = .init(x: acc, y: 0)
                view.frame.size = view.intrinsicContentSize
                return view.frame.maxX
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
            view.text = self.value[idx].formatted(.nodeNumber)
        }
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    func onDrag(_ idx: Int, _ value: NodeTextFieldEvent.Drag) {
        let phase = value.phase
        let shiftDown = value.shiftDown
        let optionDown = value.optionDown
        let dx = value.dx

        self.updateStatusBarMessage(phase)

        switch phase {
        case .began:
            self.valueAtDragStart = self.value[idx]
        default:
            break
        }

        let sensitivity = shiftDown ? 0.01 : (optionDown ? 1.0 : 0.1)
        let t = dx * sensitivity
        let newValue = (self.valueAtDragStart + t).truncateTo(fractionalDigits: 2)

        if phase == .ended {
            let oldValue = self.value(settingIndex: idx, to: self.valueAtDragStart)
            self.setValue(newValue: self.value(settingIndex: idx, to: newValue), oldValue: oldValue, registerUndo: true)
        } else {
            self.setValue(newValue: self.value(settingIndex: idx, to: newValue))
        }
    }

    func updateStatusBarMessage(_ phase: GesturePhase) {
        switch phase {
        case .began:
            self.onEvent?(.statusBarMessage(StatusBarMessage.dragFloat.rawValue))
        case .ended, .cancelled:
            self.onEvent?(.statusBarMessage(nil))
        default: break
        }
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
