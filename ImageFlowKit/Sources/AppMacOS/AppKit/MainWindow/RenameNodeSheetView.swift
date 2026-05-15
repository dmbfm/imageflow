import SharedModels
import SwiftUI
import XKit

#if os(macOS)

import AppKit

let modalSize: CGSize = .init(width: 320, height: 140)

final class RenameNodeSheetViewController: NSViewController {
    weak var delegate: Delegate?
    var node: UUID
    var text: String

    protocol Delegate: AnyObject {
        func renameNodeSheetDidConfirm(_ node: UUID, _ newName: String)
        func renameNodeSheetDidCancel()
    }

    init(_ node: UUID, _ name: String, _ delegate: Delegate) {
        self.node = node
        self.text = name
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.preferredContentSize = modalSize
    }

    @MainActor @preconcurrency required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var textField: NSTextField = {
        let view = NSTextField(string: self.text)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.focusRingType = .none
        return view
    }()

    lazy var okBtn: NSButton = {
        let view = NSButton(title: "OK", target: self, action: #selector(Self.ok))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintProminence = .primary
        return view
    }()

    lazy var cancelBtn: NSButton = {
        let view = NSButton(title: "Cancel", target: self, action: #selector(Self.cancel))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintProminence = .secondary
        return view
    }()

    lazy var titleLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Rename Node")
        view.font = .preferredFont(forTextStyle: .headline)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @objc func ok() {
        self.dismiss(nil)
        self.delegate?.renameNodeSheetDidConfirm(self.node, self.text)
    }

    @objc func cancel() {
        self.dismiss(nil)
        self.delegate?.renameNodeSheetDidCancel()
    }

    override func loadView() {
        self.view = NSView(frame: .init(origin: .zero, size: modalSize))
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLoad() {
        self.view.addSubview(self.textField)
        self.view.addSubview(self.okBtn)
        self.view.addSubview(self.cancelBtn)
        self.view.addSubview(self.titleLabel)

        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 18),
            self.textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
        ])

        NSLayoutConstraint.activate([
            self.okBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.okBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            self.cancelBtn.trailingAnchor.constraint(equalTo: self.okBtn.leadingAnchor, constant: -16),
            self.cancelBtn.bottomAnchor.constraint(equalTo: self.okBtn.bottomAnchor),
        ])
    }
}

extension RenameNodeSheetViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        self.text = self.textField.text
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        self.ok()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSText.cancelOperation(_:)) {
            self.cancel()
            return true
        }

        return false
    }
}

private class DummyDelegate: RenameNodeSheetViewController.Delegate {
    func renameNodeSheetDidConfirm(_ node: UUID, _ newName: String) {}
    func renameNodeSheetDidCancel() {}
}

private struct Representable: NSViewControllerRepresentable {
    @State var delegate: DummyDelegate = .init()
    func makeNSViewController(context: Context) -> RenameNodeSheetViewController {
        RenameNodeSheetViewController(.init(), "", self.delegate)
    }

    func updateNSViewController(_ nsViewController: RenameNodeSheetViewController, context: Context) {

    }

    typealias NSViewControllerType = RenameNodeSheetViewController

}

#Preview {
    VStack {}
        .frame(width: 600, height: 600)
        .sheet(
            isPresented: .constant(true),
            content: {
                Representable()
            }
        )
    //    let delegate = DummyDelegate()
    //    RenameNodeSheetViewController(.init(), "Bokeh Blur", delegate)
}

#endif
