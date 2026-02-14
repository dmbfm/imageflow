import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

final class EmptyControlView: PlatformCommonView, NodeControl {
    var tint: Helpers.PlatformColor = .blue

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

public final class NodeInputRowView: PlatformView {

    // MARK: - Exposed Properties

    var input: FlowNode.Input {
        didSet {
            if self.input != oldValue {
                self.update()
            }
        }
    }

    var drawPortAsConnected: Bool = false {
        didSet {
            self.portView.connected = self.drawPortAsConnected || self.input.connected
        }
    }

    var onEvent: ((Event) -> ())?

    var isEditable: Bool {
        !self.input.connected
    }

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
        let view = PortView(connected: self.input.connected, style: self.style.port)
        view.onEvent = { [weak self] event in
            switch event {
            case .drag(let data):
                self?.onEvent?(.dragPort(data))
            }
        }
        return view
    }()

    lazy var controlView: any NodeControl = {
        let view: any NodeControl =
            switch self.input.value.type {
            case .float:
                NodeNumberInput(self.input.value, isEditable: self.isEditable)
            case .int:
                NodeIntegerInput(self.input.value, isEditable: self.isEditable)
            case .bool:
                NodeBooleanInput(self.input.value, isEditable: self.isEditable)
            case .vector2, .vector3, .vector4:
                NodeVectorInput(self.input.value, isEditable: self.isEditable)
            case .image:
                NodeAssetPicker<ImageAssetPicker>(
                    self.input.value,
                    isEditable: self.isEditable,
                    delegate: self.delegate
                )
            case .color3, .color4:
                NodeColorInput(self.input.value, isEditable: self.isEditable)
            case .rect:
                NodeRectInput(self.input.value, isEditable: self.isEditable)
            case .string:
                NodeStringInput(self.input.value, isEditable: self.isEditable)
            case .lut:
                NodeAssetPicker<LutAssetPicker>(
                    self.input.value,
                    isEditable: self.isEditable,
                    delegate: self.delegate
                )
            case .affineTransform:
                EmptyControlView(value: self.input.value)
            default:
                StaticLabelNodeControl(self.input.value, "<\(self.input.value.type)>")
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
            }
        }
        return view
    }()

    // MARK: - Initializers

    init(_ input: FlowNode.Input, delegate: Delegate?, style: Style = .default) {
        self.input = input
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
        self.portView.connected = self.drawPortAsConnected || self.input.connected

        if self.input.label != self.labelView.text {
            self.labelView.text = self.input.label
            self.updateSize()
        }

        if self.input.value != self.controlView.value {
            self.controlView.value = self.input.value
        }

        if self.controlView.isEditable != self.isEditable {
            self.controlView.isEditable = self.isEditable
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
        public var labelFont: FontStyle
        public var labelColor: PlatformColor

        public static var `default`: Self {
            .init(
                port: .default,
                portLabelSpacing: 8.0,
                rowHeight: 32.0,
                labelControlSpacing: 18.0,
                labelSafetyMargin: 2.0,
                labelFont: .systemFont(size: 14, weight: .regular),
                labelColor: .secondaryLabel
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
    }
}

extension NodeInputRowView {
    fileprivate struct Preview: PlatformViewRepresentable {
        var input: FlowNode.Input = .init(
            label: "Something",
            index: 0,
            value: .float(0.5),
            semantics: .default,
            connected: false
        )
        func makeView(context: Context) -> NodeInputRowView {
            let view = NodeInputRowView(
                self.input,
                delegate: nil
            )
            view.onEvent = { log("event: \($0)") }
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
            input: .init(label: "Other", index: 1, value: .bool(true), semantics: .default, connected: true)
        )
        .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 400, minHeight: 400)
    .background(.white)
}
