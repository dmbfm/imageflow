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

struct NodeNumberTextFieldFormat: FormatStyle {
    func format(_ value: Double) -> String {
        value.formatted(
            .number
                .locale(.init(identifier: "en-US"))
                .precision(.fractionLength(2...8))
                .grouping(.never)
        )
    }
}

extension FormatStyle where Self == NodeNumberTextFieldFormat {
    static var nodeNumber: NodeNumberTextFieldFormat {
        .init()
    }
}

final class NodeNumberTextField: PlatformCommonView {
    public var value: Double {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var onEvent: ((Event) -> ())?

    enum Event {
        case valueDidChange(Change)
        case sizeDidChange
        case keyboardWillShow(windowVerticalOverlap: CGFloat, duration: CGFloat)
    }

    struct Change {
        var newValue: Double
        var oldValue: Double?
        var commit: Bool
    }

    public var tint: PlatformColor = .systemBlue

    var snap: Snap? = nil
    var forceSnap: Bool = false

    struct Snap {
        var increments: Double
        var epsilon: Double
    }

    func setValue(newValue: Double, oldValue: Double? = nil, registerUndo: Bool = false) {
        let oldValue = oldValue ?? self.value

        if newValue != oldValue {
            self.value = newValue
            self.onEvent?(.valueDidChange(.init(newValue: newValue, oldValue: oldValue, commit: registerUndo)))
        }
    }

    func emit(_ event: Event) {
        self.onEvent?(event)
    }

    lazy var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.decimalSeparator = "."
        return f
    }()

    lazy var locale: Locale = { .init(identifier: "en-US") }()

    lazy var textField: NodeTextField = {
        let view = NodeTextField(
            self.value.formatted(.nodeNumber),
            style: .default.with(\.borderColor, self.tint)
        )
        view.onEvent = { [weak self] event in
            switch event {
            case .textDidChange(let value):
                guard let self else { return }
                if let number = Double(value) {
                    self.setValue(newValue: number, registerUndo: true)
                } else {
                    if value == "" {
                        self.setValue(newValue: 0.0, registerUndo: true)
                    } else {
                        self.update()
                    }
                }
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
            case let .drag(drag):
                self?.onDrag(drag)
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self?.emit(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
            }
        }
        return view
    }()

    var isEditable: Bool {
        get {
            self.textField.isEditable
        }
        set {
            self.textField.isEditable = newValue
        }
    }

    public init(_ value: Double, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textField.isEditable = isEditable

        self.addSubview(self.textField)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        let result = self.textField.intrinsicContentSize
        return result
    }

    override func doLayout() {
        self.textField.frame.origin = .zero
        self.textField.frame.size = self.textField.intrinsicContentSize
    }

    func update() {
        self.textField.text = self.value.formatted(.nodeNumber)
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    private var valueAtDragStart: CGFloat = 0.0

    func onDrag(_ value: NodeTextFieldEvent.Drag) {

        let phase = value.phase
        let shiftDown = value.shiftDown
        let optionDown = value.optionDown
        let commandDown = value.commandDown
        let dx = value.dx

        switch phase {
        case .began:
            self.valueAtDragStart = self.value
        default:
            break
        }

        let sensitivity = shiftDown ? 0.01 : (optionDown ? 1.0 : 0.1)
        let t = dx * sensitivity
        let newValue = self.snap.maybeReduce(
            (self.valueAtDragStart + t).truncateTo(fractionalDigits: 2),
            { v, snap in
                if commandDown || self.forceSnap {
                    v.snapping(toIncrements: snap.increments, epsilon: snap.epsilon)
                } else {
                    v
                }
            }
        )

        if phase == .ended {
            self.setValue(newValue: newValue, oldValue: self.valueAtDragStart, registerUndo: true)
        } else {
            self.setValue(newValue: newValue)
        }
    }
}
