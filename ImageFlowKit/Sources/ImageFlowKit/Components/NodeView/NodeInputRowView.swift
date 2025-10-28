import Helpers
import Logging
import SwiftUI
import Values

final class NodeInputRowView: PlatformView {
    public var input: FlowNode.Input {
        didSet {
            if self.input != oldValue {
                self.update()
            }
        }
    }

    public var drawPortAsConnected: Bool = false {
        didSet {
            self.portView.connected = self.drawPortAsConnected || self.input.connected
        }
    }

    public var onEvent: ((Event) -> ())?

    // MARK: - Private

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
                NodeNumberInput(self.input.value)
            case .bool:
                NodeBooleanInput(self.input.value)
            case .vector2, .vector3, .vector4:
                NodeVectorInput(self.input.value)
            default:
                StaticLabelNodeControl(self.input.value, "<\(self.input.value.type)>")
            }
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.invalidateIntrinsicContentSize()
                #if os(macOS)
                self.needsLayout = true
                #endif
                self.onEvent?(.sizeDidChange)
                break
            case .valueDidChange(let value):
                self.onEvent?(.valueDidChange(value))
                break
            }
        }
        return view
    }()

    // MARK: - Initializers

    init(_ input: FlowNode.Input, style: Style = .default) {
        self.input = input
        self.style = style

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
    }

    private func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - Layout

    #if os(macOS)

    override var isFlipped: Bool {
        true
    }

    override func layout() {
        self.doLayout()
    }
    #endif

    #if os(iOS)
    override func layoutSubviews() {
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

    override var intrinsicContentSize: CGSize {
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
    struct Style: Sendable, Hashable, With {
        var port: PortView.Style
        var portLabelSpacing: CGFloat
        var rowHeight: CGFloat
        var labelControlSpacing: CGFloat
        var labelSafetyMargin: CGFloat
        var labelFont: FontStyle
        var labelColor: PlatformColor

        static var `default`: Self {
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

@MainActor
protocol NodeInputRowViewProtocol {
    var input: FlowNode.Input { get set }
    var drawPortAsConnected: Bool { get set }
    var onEvent: ((NodeInputRowView.Event) -> ())? { get set }
    init(_ input: FlowNode.Input)
}

extension NodeInputRowView {
    public enum Event {
        case sizeDidChange
        case valueDidChange(Value)
        case dragPort(PortView.DragData)
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
                self.input
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
