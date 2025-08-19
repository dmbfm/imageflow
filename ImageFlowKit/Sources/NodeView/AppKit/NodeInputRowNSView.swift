#if canImport(AppKit)

import AppKit
import CommonUtils
import Models
import NodeControls
import Values

// MARK: - NodeInputRowNSView

final class NodeInputRowNSView: NSView {

    // MARK: - Initializers

    init(_ input: FlowNode.Input) {
        self.input = input

        super.init(frame: .zero)

        self.addSubview(self.portView)
        self.addSubview(self.labelView)
        self.addSubview(self.controlView)

        self.update(nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public

    public var input: FlowNode.Input {
        didSet {
            if self.input != oldValue {
                self.update(oldValue)
            }
        }
    }

    public enum Event {
        case sizeDidChange
        case valueDidChange(Value)
    }

    public var onEvent: ((Event) -> ())?

    // MARK: - Private

    private static let labelSafetyMargin: CGFloat = 2.0

    lazy var portView: PortView = {
        PortView()
    }()

    lazy var labelView: NSTextField = {
        NSTextField(nodeRowLabelWithString: "")
    }()

    lazy var controlView: any NodeControl = {
        let view: any NodeControl =
            switch self.input.value.type {
            case .float:
                NodeNumberInput(self.input.value)
            default:
                StaticLabelNodeControl(self.input.value, "<\(self.input.value.type)>")
            }
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.invalidateIntrinsicContentSize()
                self.needsLayout = true
                self.onEvent?(.sizeDidChange)
                break
            case .valueDidChange(let value):
                self.onEvent?(.valueDidChange(value))
                break
            }
        }
        return view
    }()

    private func update(_ oldValue: FlowNode.Input?) {
        if self.input.connected != oldValue?.connected {
            self.portView.connected = self.input.connected
        }

        if self.input.label != oldValue?.label {
            self.labelView.stringValue = self.input.label
            self.invalidateIntrinsicContentSize()
            self.needsLayout = true
            self.onEvent?(.sizeDidChange)
        }

        if self.input.value != oldValue?.value {
            self.controlView.value = self.input.value
        }
    }

    // MARK: - Internal

    override var isFlipped: Bool {
        true
    }

    override var intrinsicContentSize: NSSize {
        let portSize = self.portView.intrinsicContentSize
        let labelSize = self.labelView.intrinsicContentSize + .init(width: Self.labelSafetyMargin, height: 0)
        let controlSize = self.controlView.intrinsicContentSize

        let width =
            portSize.width + labelSize.width + controlSize.width + Design.default.portLabelSpacing
            + Design.default.labelControlSpacing
        let height = max(portSize.height, labelSize.height, controlSize.height)

        return .init(width: width, height: height)
    }

    override func layout() {
        let labelSize = self.labelView.intrinsicContentSize + .init(width: Self.labelSafetyMargin, height: 0)
        self.portView.frame = .init(origin: .zero, size: self.portView.intrinsicContentSize)
        self.labelView.frame = .init(
            origin: .init(x: self.portView.frame.maxX + Design.default.portLabelSpacing, y: 0),
            size: labelSize
        )

        controlView.frame = CGRect(
            origin: .init(x: self.bounds.maxX - controlView.intrinsicContentSize.width, y: 0),
            size: controlView.intrinsicContentSize
        )  //.init(center: CGRect(x: 0, y: 0), size: controlView.intrinsicContentSize)
        Layout.align(
            views: [self.portView, self.labelView, controlView],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }
}

extension NSTextField {
    convenience init(nodeRowLabelWithString label: String) {
        self.init(labelWithString: label)
        self.font = .systemFont(ofSize: 10)
        self.textColor = .secondaryLabelColor
        // self.fittingSize
        // self.lineBreakMode = .byClipping
        self.maximumNumberOfLines = 1
        // self.allowsDefaultTighteningForTruncation = true
        // self.cell?.lineBreakMode = .byWordWrapping
    }
}

#endif
