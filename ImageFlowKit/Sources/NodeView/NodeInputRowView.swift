import Backend
import Helpers
import SharedModels
import SwiftUI
import Values
import XKit

final class EmptyControlView: XViewEx, NodeControl {
    var tint: XColor = .blue

    var value: Values.Value

    var onEvent: ((NodeControlEvent) -> ())?

    var context: NodeControlContext = .init()

    init(value: Value) {
        self.value = value
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize { .zero }
}

public final class NodeInputRowView: XView {

    // MARK: - ViewModel

    struct ViewModel: Equatable {
        var input: FlowNode.Input
        var semantics: ValueSemantics
        var drawPortAsConnected: Bool
        var placement: NodeInputSchema.EditorPlacement.NodeView

        var isEditable: Bool {
            !self.input.connected
        }

        func sameValueType(as other: ViewModel) -> Bool {
            self.input.value.type == other.input.value.type
        }
    }

    // MARK: - Exposed Properties

    var vm: ViewModel {
        didSet {
            if self.vm != oldValue {
                self.update()
            }
        }
    }

    var onEvent: ((Event) -> ())?

    // MARK: - Exposed Types

    typealias Delegate = NodeAssetPickerDelegate

    // MARK: - Private Properties

    private weak var delegate: Delegate?
    private var style: Style

    #if os(macOS)
    lazy var labelView: NSTextField = {
        NSTextField(nodeRowLabelWithString: "", font: self.style.labelFont.font, color: self.style.labelColor)
    }()
    #endif

    #if os(iOS)
    lazy var labelView: UILabel = {
        let view = UILabel(nodeRowLabelWithString: "", font: self.style.labelFont.font, color: self.style.labelColor)
        return view
    }()
    #endif

    lazy var portView: PortView = {
        let view = PortView(connected: self.vm.input.connected, style: self.style.port)
        view.onEvent = { [weak self] event in
            switch event {
            case .drag(let data):
                self?.onEvent?(.dragPort(data))
            }
        }

        #if os(macOS)
        view.toolTip = "\(self.vm.input.value.type.displayName)"
        #else
        view.addInteraction(UIToolTipInteraction(defaultToolTip: "\(self.vm.input.value.type.displayName)"))
        #endif

        return view
    }()

    lazy var controlView: any NodeControl = {

        if self.vm.placement == .hiddenControl {
            return EmptyControlView(value: .float(0))
        }

        let view: any NodeControl =
            switch self.vm.input.value.type {
            case .float:
                switch self.vm.semantics {
                case .float(.angle(.some(let range))):
                    if abs(range.span - 2.0 * .pi) < 0.001 {
                        NodeAngleInput(self.vm.input.value, range: nil, isEditable: self.vm.isEditable)
                    } else {
                        NodeAngleInput(self.vm.input.value, range: range, isEditable: self.vm.isEditable)
                    }
                case .float(.angle(.none)):
                    NodeAngleInput(self.vm.input.value, range: nil, isEditable: self.vm.isEditable)
                case .float(.range(let range)):
                    NodeNumberInput(self.vm.input.value, range: range, isEditable: self.vm.isEditable)
                default:
                    NodeNumberInput(self.vm.input.value, isEditable: self.vm.isEditable)
                }
            case .int:
                switch self.vm.semantics {
                case .integer(.range(let range)):
                    NodeIntegerInput(
                        self.vm.input.value,
                        range: range,
                        isEditable: self.vm.isEditable
                    )
                case .integer(.partialRangeFrom(let lowerBound)):
                    NodeIntegerInput(
                        self.vm.input.value,
                        lowerBound: lowerBound,
                        isEditable: self.vm.isEditable,
                    )
                case .integer(.picker(let options)):
                    NodeOptionPickerInput(
                        self.vm.input.value,
                        options: options,
                        isEditable: self.vm.isEditable
                    )
                default:
                    NodeIntegerInput(
                        self.vm.input.value,
                        isEditable: self.vm.isEditable
                    )
                }
            case .bool:
                NodeBooleanInput(self.vm.input.value, isEditable: self.vm.isEditable)
            case .vector2, .vector3, .vector4:
                NodeVectorInput(self.vm.input.value, isEditable: self.vm.isEditable)
            case .image:
                NodeAssetPicker<ImageAssetPicker>(
                    self.vm.input.value,
                    isEditable: self.vm.isEditable,
                    delegate: self.delegate
                )
            case .color4:
                NodeColorInput(self.vm.input.value, isEditable: self.vm.isEditable)
            case .rect:
                NodeRectInput(self.vm.input.value, isEditable: self.vm.isEditable)
            case .string:
                NodeStringInput(self.vm.input.value, isEditable: self.vm.isEditable)
            case .lut:
                NodeAssetPicker<LutAssetPicker>(
                    self.vm.input.value,
                    isEditable: self.vm.isEditable,
                    delegate: self.delegate
                )
            case .affineTransform, .matrix2x2, .matrix3x3, .matrix5x5, .matrix7x7, .gradientData:
                EmptyControlView(value: self.vm.input.value)
            default:
                StaticLabelNodeControl(self.vm.input.value, "<\(self.vm.input.value.type)>")
            }
        view.clipsToBounds = false
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.invalidateIntrinsicContentSize()
                #if os(macOS)
                self.needsLayout = true
                #endif
                self.onEvent?(.sizeDidChange)
            case .valueDidChange(let value):
                self.onEvent?(.valueDidChange(value))
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self.onEvent?(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
            case .statusBarMessage(let message):
                self.onEvent?(.statusBarMessage(message))
            }
        }
        return view
    }()

    // MARK: - Initializers

    init(_ vm: ViewModel, delegate: Delegate?, style: Style = .default) {
        self.vm = vm
        self.style = style
        self.delegate = delegate

        super.init(frame: .zero)

        self.addSubview(self.portView)
        self.addSubview(self.labelView)
        self.addSubview(self.controlView)

        self.update()
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updating

    private func update() {
        self.portView.connected = self.vm.drawPortAsConnected || self.vm.input.connected

        if self.vm.input.label != self.labelView.text {
            self.labelView.text = self.vm.input.label
            self.updateSize()
        }

        if self.vm.input.value != self.controlView.value {
            self.controlView.value = self.vm.input.value
        }

        if self.controlView.isEditable != self.vm.isEditable {
            self.controlView.isEditable = self.vm.isEditable
        }
    }

    private func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - Layout

    #if os(macOS)

    public override var isFlipped: Bool {
        true
    }

    public override func layout() {
        self.doLayout()
    }
    #endif

    #if os(iOS)
    public override func layoutSubviews() {
        self.doLayout()
    }
    #endif

    private func doLayout() {
        let labelSize = self.labelView.intrinsicContentSize + .init(width: style.labelSafetyMargin, height: 0)

        self.portView.frame = .init(origin: .zero, size: self.portView.intrinsicContentSize)

        self.labelView.frame = .init(
            origin: .init(x: self.portView.frame.maxX + style.portLabelSpacing, y: 0),
            size: labelSize
        )

        controlView.frame = CGRect(
            origin: .init(x: self.bounds.maxX - controlView.intrinsicContentSize.width, y: 0),
            size: controlView.intrinsicContentSize
        )

        Layout.align(
            views: [self.portView, self.labelView, controlView],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }

    public override var intrinsicContentSize: CGSize {
        let portSize = self.portView.intrinsicContentSize
        let labelSize = self.labelView.intrinsicContentSize + .init(width: style.labelSafetyMargin, height: 0)
        let controlSize = self.controlView.intrinsicContentSize

        let width =
            portSize.width + labelSize.width + controlSize.width + style.portLabelSpacing
            + style.labelControlSpacing
        // let height = max(portSize.height, labelSize.height, controlSize.height)
        let height = self.style.rowHeight

        return .init(width: width, height: height)
    }
}

extension NodeInputRowView {
    public struct Style: Sendable, Hashable, With {
        public var port: PortView.Style
        public var portLabelSpacing: CGFloat
        public var rowHeight: CGFloat
        public var labelControlSpacing: CGFloat
        public var labelSafetyMargin: CGFloat
        public var labelFont: XFontStyle
        public var labelColor: XColor

        public static var `default`: Self {
            .init(
                port: .default,
                portLabelSpacing: 8.0,
                rowHeight: 32.0,
                labelControlSpacing: 18.0,
                labelSafetyMargin: 2.0,
                labelFont: .systemFont(size: 14, weight: .regular),
                labelColor: .system.secondaryLabel
            )
        }
    }
}

#if os(macOS)
extension NSTextField {
    convenience init(
        nodeRowLabelWithString label: String,
        font: NSFont = .systemFont(ofSize: 14),
        color: NSColor = .secondaryLabelColor
    ) {
        self.init(labelWithString: label)
        self.font = font
        self.textColor = color
        self.maximumNumberOfLines = 1
    }
}
#endif

#if os(iOS)
import UIKit
extension UILabel {
    convenience init(
        nodeRowLabelWithString text: String,
        font: UIFont = .systemFont(ofSize: 14),
        color: UIColor = .label
    ) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = color
    }
}
#endif

extension NodeInputRowView {
    public enum Event {
        case sizeDidChange
        case valueDidChange(Value)
        case dragPort(PortView.DragData)
        case keyboardWillShow(windowVerticalOverlap: CGFloat, duration: CGFloat)
        case statusBarMessage(String?)
    }
}

extension NodeInputRowView {
    fileprivate struct Preview: XViewRepresentable {
        var input: FlowNode.Input = .init(
            label: "Something",
            index: 0,
            value: .float(0.5),
            connected: false
        )
        func makeView(context: Context) -> NodeInputRowView {
            let view = NodeInputRowView(
                .init(input: self.input, semantics: .default, drawPortAsConnected: false, placement: .visible),
                delegate: nil
            )
            view.onEvent = { _ in }
            return view
        }

        func updateView(_ view: NodeInputRowView, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading, spacing: 0) {
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))

        NodeInputRowView.Preview(
            input: .init(label: "Other", index: 1, value: .bool(true), connected: true)
        )
        .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 400, minHeight: 400)
    .background(.white)
}
