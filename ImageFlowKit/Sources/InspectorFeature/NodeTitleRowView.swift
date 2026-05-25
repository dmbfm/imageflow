import Backend
import Helpers
import SharedModels
import SwiftUI
import XKit

class NodeTitleRowView: XViewEx {
    var icon: String {
        didSet {
            if self.icon != oldValue {
                self.iconView.image = .init(systemSymbolName: self.icon, accessibilityDescription: nil)
            }
        }
    }

    var name: String {
        didSet {
            if self.nameTextField.text != self.name {
                self.nameTextField.text = self.name
            }
        }
    }

    var locked: Bool {
        didSet {
            if self.locked != oldValue {
                self.updateLocked()
            }
        }
    }

    weak var delegate: Delegate? = nil

    lazy var iconView: XImageView = {
        let view = XImageView(
            image: .init(
                systemSymbolName: icon,
                accessibilityDescription: nil
            )
                ?? .init()
        )
        view.symbolConfiguration = .init(textStyle: .headline, scale: .large).applying(
            .init(hierarchicalColor: .secondaryLabelColor)
        )
        return view
    }()

    lazy var nameTextField: XTextField = {
        let view = NodeNameTextField()
        view.maximumNumberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.text = self.name
        view.font = .preferredFont(forTextStyle: .headline)
        view.drawsBackground = false
        view.isBordered = false
        view.focusRingType = .none
        view.delegate = self
        return view
    }()

    lazy var lockButtonView: XButton = {
        let view = XButton(
            image: .init(systemSymbolName: .systemIconLock, accessibilityDescription: nil)!,
            target: nil,
            action: nil
        )
        view.isBordered = false
        return view
    }()

    var dummyContextMenu: NSMenu {
        let menu = NSMenu()
        menu.items = [
            .init(title: "Hello", action: nil, keyEquivalent: ""),
            .init(title: "World!", action: nil, keyEquivalent: ""),
        ]
        return menu
    }

    lazy var nodeTitleEllipsisButton: EllipsisMenuButton = {
        let view = EllipsisMenuButton(
            image:
                .init(systemSymbolName: "ellipsis", accessibilityDescription: nil)!.withSymbolConfiguration(
                    .init(scale: .large)
                )!
        )
        view.onMouseDown = { [weak self] event in
            if let menu = self?.dummyContextMenu {
                NSMenu.popUpContextMenu(menu, with: event, for: view)
            }
        }
        return view
    }()

    init(icon: String, name: String, locked: Bool) {
        self.name = name
        self.icon = icon
        self.locked = locked

        super.init(frame: .zero)

        self.addSubview(self.iconView)
        self.addSubview(self.nameTextField)
        self.addSubview(self.lockButtonView)
        self.addSubview(self.nodeTitleEllipsisButton)

        self.updateLocked()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLocked() {
        self.lockButtonView.image = .init(
            systemSymbolName: self.locked ? .systemIconLock : .systemIconLockOpen,
            accessibilityDescription: nil
        )
    }

    let iconSize = CGSize(width: 20, height: 20)

    var layoutEntries: [XKit::VStackLayout.Entry] {
        [
            .init(view: self.iconView, sizingMode: .fixed(iconSize)),
            .init(view: self.nameTextField, sizingMode: .flex(.intrinsic)),
            .init(view: self.lockButtonView, sizingMode: .intrinsic),
            .init(view: self.nodeTitleEllipsisButton, sizingMode: .fixed(.init(width: 20, height: 20))),
        ]
    }
    var layoutSpacing: XKit::VStackLayout.Spacing {
        .custom([
            0.0,
            12.0,
            6.0,
        ])
    }

    override var intrinsicContentSize: CGSize {
        VStackLayout.intrinsicContentSize(self.layoutEntries, self.bounds, spacing: self.layoutSpacing)
    }

    override func layout() {
        super.layout()
        VStackLayout.layout(self.layoutEntries, self.bounds, spacing: self.layoutSpacing)
    }
}

extension NodeTitleRowView {
    protocol Delegate: AnyObject {
        func nodeTitleRowViewLockButtonClick(_: NodeTitleRowView)
        func nodeTitleRowViewContextMenu() -> XMenu?
        func nodeTitleRowViewDidEditName(_ value: String)
    }
}

extension NodeTitleRowView: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.nameTextField.abortEditing()
            return true
        } else if commandSelector == #selector(NSStandardKeyBindingResponding.insertNewline(_:)) {
            self.nameTextField.window?.makeFirstResponder(nil)
            self.delegate?.nodeTitleRowViewDidEditName(self.nameTextField.text)
            return true
        }
        return false
    }

    func controlTextDidChange(_ obj: Notification) {

    }

    func controlTextDidEndEditing(_ obj: Notification) {
        print("!!")
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

extension NodeTitleRowView {
    class NodeNameTextField: XTextField {
        override var acceptsFirstResponder: Bool { false }
    }
}

// MARK: - Previews

fileprivate struct PreviewRepresentable: XViewRepresentable {

    func makeView(context: Context) -> NodeTitleRowView {
        let s = NodeTitleRowView(icon: NodeKind.combineValue(.vector4).icon, name: "Float Number", locked: false)
        return s
    }

    func updateView(_ view: NodeTitleRowView, context: Context) {
        view.needsLayout = true
        view.updateConstraints()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, view: NodeTitleRowView, context: Context) -> CGSize? {
        let size = CGSize(
            width: proposal.replacingUnspecifiedDimensions().width,
            height: view.intrinsicContentSize.height
        )
        print("size: \(size)")
        return size
    }
}

#Preview {
    VStack {
        PreviewRepresentable()
            //            .fixedSize()
            .border(.teal.opacity(0.1))
            .padding()
    }
}
