import Backend
import Combine
import ComponentKit
import Helpers
import SharedModels
import SwiftUI
import XKit

final class NodeTitleView: XView, Rx {

    var icon: String {
        didSet {
            if self.icon != oldValue {
                self.iconView.systemName = self.icon
            }
        }
    }

    var name: String {
        get { self.nameTextField.text }
        set { self.nameTextField.text = newValue }
    }

    var locked: Bool {
        didSet {
            if self.locked != oldValue {
                self.updateLockIcon()
            }
        }
    }

    var nodeContextMenuProvider: (() -> XMenu?)?

    var lockButtonPublisher: PassthroughSubject<(), Never> {
        self.lockButtonView.publisher
    }

    var didEditNodeName: PassthroughSubject<String, Never> = .init()

    var cancellables: Set<AnyCancellable> = []

    lazy var iconView: Icon = {
        Icon(systemName: self.icon)
            .with(\.fontConfiguration, .preferred(.headline))
            .with(\.scale, .large)
    }()

    lazy var nameTextField: NodeNameTextField = {
        let view = NodeNameTextField()
        view.maximumNumberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = .preferredFont(forTextStyle: .headline)
        view.drawsBackground = false
        view.isBordered = false
        view.focusRingType = .none
        view.delegate = self
        return view
    }()

    lazy var lockButtonView: ComponentKit::Button = {
        Button(
            "",
            image: XImage(systemSymbolName: .systemIconLock, accessibilityDescription: nil),
            buttonSize: .regular
        )
        .with(\.isBordered, false)
    }()

    lazy var nodeTitleEllipsisButton: EllipsisMenuButton = {
        let view = EllipsisMenuButton(
            image:
                .init(systemSymbolName: "ellipsis", accessibilityDescription: nil)!
                .withSymbolConfiguration(.init(scale: .large))!
        )
        view.onMouseDown = { [weak self, weak view] event in
            if let view, let menu = self?.nodeContextMenuProvider?() {
                NSMenu.popUpContextMenu(menu, with: event, for: view)
            }
        }
        return view
    }()

    lazy var stackView: ComponentKit::HStack = {
        let view = HStack(
            alignment: .firstTextBaseline,
            views: [
                self.iconView, self.nameTextField, self.lockButtonView, self.nodeTitleEllipsisButton,
            ]
        )
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(icon: String, name: String, locked: Bool) {
        self.icon = icon
        self.locked = locked

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.stackView.clipsToBounds = false
        self.name = name

        self.setupViews()
        self.update()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()
    }

    func update() {
        self.updateLockIcon()
    }

    func updateLockIcon() {
        self.lockButtonView.image = .init(
            systemSymbolName: self.locked ? .systemIconLock : .systemIconLockOpen,
            accessibilityDescription: nil
        )
    }

    override var intrinsicContentSize: NSSize {
        .init(
            width: Self.noIntrinsicMetric,
            height: self.stackView.subviews.reduce(0.0, { acc, view in max(acc, view.intrinsicContentSize.height) }) + 4
        )
    }
}

extension NodeTitleView: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.nameTextField.abortEditing()
            return true
        } else if commandSelector == #selector(NSStandardKeyBindingResponding.insertNewline(_:)) {
            self.nameTextField.window?.makeFirstResponder(nil)
            self.didEditNodeName.send(self.name)
            return true
        }
        return false
    }

    func controlTextDidChange(_ obj: Notification) {

    }

    func controlTextDidEndEditing(_ obj: Notification) {
        Task {
            self.nameTextField.window?.makeFirstResponder(nil)
        }
    }

    func controlTextDidBeginEditing(_ obj: Notification) {

    }
}

class EllipsisMenuButton: XImageView {
    var onMouseDown: ((XEvent) -> ())?
    override func mouseDown(with event: XEvent) {
        self.onMouseDown?(event)
    }
}

extension NodeTitleView {
    class NodeNameTextField: XTextField {

        var isFocusable: Bool = false

        override var acceptsFirstResponder: Bool { self.isFocusable }
    }
}

// MARK: - Previews

fileprivate struct PreviewRepresentable: XViewRepresentable {

    func makeView(context: Context) -> NodeTitleView {
        let s = NodeTitleView(icon: NodeKind.combineValue(.vector4).icon, name: "Float Number", locked: false)
        return s
    }

    func updateView(_ view: NodeTitleView, context: Context) {
        view.needsLayout = true
        view.updateConstraints()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, view: NodeTitleView, context: Context) -> CGSize? {
        let size = CGSize(
            width: proposal.replacingUnspecifiedDimensions().width,
            height: view.intrinsicContentSize.height
        )
        return size
    }
}

#Preview {
    VStack {
        XSimpleViewRepresentable(
            NodeTitleView(icon: NodeKind.valueNode(.color4).icon, name: "Some Node Name", locked: false)
        )
        .frame(minWidth: 280)
        .fixedSize()
        .border(.teal.opacity(0.1))
        .padding()
    }
}
