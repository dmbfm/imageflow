import Backend
import SharedModels
import SwiftUI
import XKit

final class NodeSelectedView: XViewEx {

    var node: FlowNode = .init(kind: .valueNode(.float), name: "Float Node") {
        didSet {
            // TODO: Update view when node changes

            // if self.node.name != oldValue.name {
            //     self.nodeTitleRowView.name = self.node.name
            // }
        }
    }

    var insets: XEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)

    weak var delegate: Delegate?

    class RootStackView: XStackView { override var isFlipped: Bool { true } }

    lazy var scrollView: XScrollView = {
        let view = XScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hasVerticalScroller = true
        view.hasHorizontalScroller = false
        view.documentView = self.rootStackView
        view.drawsBackground = false
        return view
    }()

    lazy var rootStackView: XStackView = {
        let view = RootStackView(views: [
            self.nodeTitleRowView,
            self.nodeTypeBlockView,
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .vertical
        view.edgeInsets = self.insets
        view.alignment = .leading
        //        NSLayoutConstraint.activate([
        //            self.nodeTypeBlockView.leadingAnchor.constraint(equalTo: self.rootStackView.leadingAnchor)
        //        ])
        return view
    }()

    lazy var nodeTitleRowView: NodeTitleRowView = {
        let view = NodeTitleRowView(icon: self.node.kind.icon, name: self.node.name, locked: false)
        return view
    }()

    lazy var nodeTypeBlockView: NodeTypeBlockView = {
        let view = NodeTypeBlockView()
        //        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.onPickKind = { [weak self] kind in self?.delegate?.nodeInpector(userSelectedNodeKind: kind) }
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.addSubview(self.scrollView)

        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.rootStackView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
            ),
            self.rootStackView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
            ),
            self.rootStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
        ])

        //        NSLayoutConstraint.activate([
        //            self.nodeTypeBlockView.leadingAnchor.constraint(equalTo: self.rootStackView.leadingAnchor),
        //            self.nodeTypeBlockView.trailingAnchor.constraint(equalTo: self.rootStackView.trailingAnchor),
        //        ])
    }
}

extension NodeSelectedView {
    protocol Delegate: AnyObject {
        func nodeInpector(userSelectedNodeKind kind: NodeKind)
    }
}

// MARK: - NodeTypeBlockView

final class NodeTypeBlockView: XViewEx {

    public var kinds: [NodeKind] = [.valueNode(.float), .valueNode(.int), .valueNode(.image)] {
        didSet {
            if self.kinds != oldValue {
                self.update()
            }
        }
    }

    public var currentKind: NodeKind = .valueNode(.float) {
        didSet {
            if self.currentKind != oldValue {
                self.update()
            }
        }
    }

    public var onPickKind: ((NodeKind) -> ())?

    var shouldShowPicker: Bool {
        self.kinds.count > 1
    }

    var isShowingPicker: Bool {
        self.valuePickerView.superview != nil
    }

    var isShowingLabel: Bool {
        self.valueLabelView.superview != nil
    }

    lazy var blockView: BlockView = {
        let view = BlockView(self.stackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthSizingMode = .fill
        view.heightSizingMode = .contentIntrinsic
        return view
    }()

    class StackView: XStackView {
        override var intrinsicContentSize: CGSize {
            .init(
                width: XView.noIntrinsicMetric,
                height: self.arrangedSubviews.reduce(0.0, { acc, view in max(acc, view.intrinsicContentSize.height) })
            )
        }
    }

    lazy var stackView: XStackView = {
        let view = XStackView()
        view.addArrangedSubview(self.labelView)
        view.orientation = .horizontal
        view.alignment = .firstBaseline
        return view
    }()

    lazy var labelView: XLabel = {
        let label = XLabel(labelWithString: "Node Type")
        label.setContentCompressionResistancePriority(.defaultLow - 2, for: .horizontal)
        return label
    }()

    lazy var valueLabelView: XLabel = {
        let label = XLabel(labelWithString: "Value")
        label.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return label
    }()

    lazy var valuePickerView: NSPopUpButton = {
        let view = NSPopUpButton()
        view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        view.target = self
        view.action = #selector(Self.pickerHandler)
        return view
    }()

    @objc func pickerHandler() {
        if let kind = self.kinds.first(where: { $0.displayName == self.valuePickerView.selectedItem?.title }) {
            self.onPickKind?(kind)
        }
    }

    func refreshPicker() {
        self.valuePickerView.removeAllItems()
        for kind in self.kinds {
            self.valuePickerView.addItem(withTitle: kind.displayName)
        }
    }

    override var intrinsicContentSize: NSSize {
        //        .init(width: NSView.noIntrinsicMetric, height: 80)
        self.blockView.intrinsicContentSize
    }

    init() {
        super.init(frame: .zero)
        self.setupViews()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setupViews() {
        self.addSubview(self.blockView)
        self.refreshPicker()

        NSLayoutConstraint.activateConstraint(self.blockView, toFill: self)

        //        self.update()
    }

    override func viewDidMoveToWindow() {
        self.update()
    }

    func update() {
        // Refresh picker
        self.refreshPicker()

        // Update label/picker visibility
        if self.shouldShowPicker {
            if self.isShowingLabel {
                self.valueLabelView.removeFromSuperview()
            }
            if !self.isShowingPicker {
                self.stackView.addView(self.valuePickerView, in: .trailing)
            }
        } else {
            if self.isShowingPicker {
                self.valuePickerView.removeFromSuperview()
            }
            if !self.isShowingLabel {
                self.stackView.addView(self.valueLabelView, in: .trailing)
            }
        }

        // Update the selected picker item
        if self.isShowingPicker {
            if self.valuePickerView.selectedItem?.title != self.currentKind.displayName {
                self.valuePickerView.selectItem(withTitle: self.currentKind.displayName)
            }
        }

        self.stackView.invalidateIntrinsicContentSize()
        self.invalidateIntrinsicContentSize()
    }
}

// MARK: - Previews

#Preview {
    VStack {
        XSimpleViewRepresentable(
            {
                let view = NodeSelectedView()
                return view
            }()
        )
        .frame(width: 320)
        .border(.red.opacity(0.12))
        .padding(50)
    }
}
