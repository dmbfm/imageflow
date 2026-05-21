#if canImport(AppKit)

import AppKit
import SwiftUI
import SharedModels
import Design
import XKit

private let popoverSize: CGSize = .init(width: 400, height: 200)

public final class NodePaletteSearchPopoverController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
    NSTextFieldDelegate
{

    // MARK: Internal Properties

    var searchText: String = "" {
        didSet {
            if self.searchText != oldValue {
                self.nodeListTableView.reloadData()
            }
        }
    }

    var onPick: ((NodePaletteItem) -> ())?

    var items: [NodePaletteItem] {
        NodePaletteService.shared.items(searchText: self.searchText)
    }

    // MARK: - Initialization

    public init(_ onPick: ((NodePaletteItem) -> ())? = nil) {
        self.onPick = onPick
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Types

    class StackView: NSStackView {
        override func performKeyEquivalent(with event: NSEvent) -> Bool {
            if let vc = self.window?.contentViewController {
                return vc.performKeyEquivalent(with: event)
            } else {
                return super.performKeyEquivalent(with: event)
            }
        }
    }
    class TopView: NSView {}
    class BottomView: NSView {}
    class NodeListScrollView: NSScrollView {}
    class SearchTextField: NSTextField {}

    class RowView: NSTableRowView {
        var _value: Bool = false
        override var isEmphasized: Bool {
            get { self._value }
            set {}
        }
        override func drawSelection(in dirtyRect: NSRect) {
            NSColor.systemOrange.withAlphaComponent(0.4).setFill()
            self.bounds.fill()
        }
    }

    // MARK: - Lazy Properties

    lazy var stackView: NSStackView = {
        let view = StackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .vertical
        view.addArrangedSubview(self.topView)
        view.addArrangedSubview(self.bottomView)
        view.spacing = 0
        return view
    }()

    lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        return view
    }()

    lazy var bottomView: BottomView = {
        let view = BottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        return view
    }()

    lazy var nodeListScrollView: NodeListScrollView = {
        let view = NodeListScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = self.nodeListTableView
        view.wantsLayer = true
        view.layer?.borderWidth = 2
        view.layer?.borderColor = .red
        view.hasVerticalScroller = true
        view.hasHorizontalScroller = false
        view.drawsBackground = false
        return view
    }()

    lazy var nodeListTableView: NodeSearchPopoverListView = {
        let view = NodeSearchPopoverListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.headerView = nil
        view.delegate = self
        view.dataSource = self
        view.style = .plain
        view.backgroundColor = .clear
        view.selectionHighlightStyle = .regular

        let column = NSTableColumn()
        view.addTableColumn(column)

        view.onClick = { [weak self] in
            _ = self?.submit()
        }

        return view
    }()

    lazy var searchTextField: SearchTextField = {
        let view = SearchTextField()
        view.text = self.searchText
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bezelStyle = .roundedBezel
        view.clipsToBounds = false
        view.focusRingType = .none
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.drawsBackground = true
        view.delegate = self
        return view
    }()

    // MARK: - NSViewController

    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let prev =
            (event.modifierFlags.contains(.control) && event.keyCode == KeyCode.p)
        let next =
            (event.modifierFlags.contains(.control) && event.keyCode == KeyCode.n)

        if prev {
            self.nodeListTableView.selectPrev()
            return true
        } else if next {
            self.nodeListTableView.selectNext()
            return true
        }

        return super.performKeyEquivalent(with: event)
    }

    public override func loadView() {
        self.preferredContentSize = popoverSize
        self.view = self.stackView
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.setContentHuggingPriority(.defaultLow, for: .horizontal)

        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: self.nodeListScrollView.contentView,
            queue: .main,
            using: { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self,
                        let location = self.view.window?.mouseLocationOutsideOfEventStream
                    else {
                        return
                    }
                    self.nodeListTableView.updateSelection(mouseWindowLocation: location)
                }
            }
        )
    }

    public override func viewDidLoad() {

        // Add subviews
        self.topView.addSubview(self.searchTextField)
        self.bottomView.addSubview(self.nodeListScrollView)

        self.topView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Configure search text field
        NSLayoutConstraint.activate([
            self.searchTextField.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: -4),
            self.searchTextField.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor),
            self.searchTextField.widthAnchor.constraint(equalToConstant: 380),
        ])

        // Configure scroll view
        NSLayoutConstraint.activate([
            self.nodeListScrollView.widthAnchor.constraint(equalTo: self.bottomView.widthAnchor),
            self.nodeListScrollView.heightAnchor.constraint(equalTo: self.bottomView.heightAnchor),
            self.nodeListScrollView.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor),
            self.nodeListScrollView.topAnchor.constraint(equalTo: self.bottomView.topAnchor),
        ])
    }

    // MARK: - NSTableViewDataSource

    public func numberOfRows(in tableView: NSTableView) -> Int {
        self.items.count
    }

    // MARK: - NSTableViewDelegate

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let items = self.items
        if items.indices.contains(row) {
            return NodeSearchPopoverListItemView(item: items[row])
        } else {
            return nil
        }
    }

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = RowView()
        return view
    }

    // MARK: - NSTextFieldDelegate

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            return self.submit()
        }
        return false
    }

    public func controlTextDidChange(_ obj: Notification) {
        self.searchText = self.searchTextField.text
    }

    // MARK: - Methods

    func submit() -> Bool {
        let row = self.nodeListTableView.selectedRow

        if row >= 0, self.items.indices.contains(row) {
            self.dismiss(nil)
            self.onPick?(self.items[row])
            return true
        } else {
            return false
        }
    }
}

// MARK: - Previews

class PreviewController: NSViewController {

    override func loadView() {
        self.view = NSView()
    }

    var btn: NSButton!

    override func viewDidLoad() {
        let btn = NSButton(title: "Show", target: self, action: #selector(Self.onClick))
        btn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(btn)

        btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        btn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.btn = btn
    }

    @objc func onClick() {
        self.present(
            NodePaletteSearchPopoverController(),
            asPopoverRelativeTo: self.btn.frame,
            of: self.view,
            preferredEdge: .minY,
            behavior: .transient,
            hasFullSizeContent: false
        )
    }
}

private struct ContentRepresentable: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> some NSViewController {
        NodePaletteSearchPopoverController()
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
}

private struct PreviewRepresentable: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> some NSViewController {
        PreviewController()
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
}

#Preview {
    VStack {
        ContentRepresentable()
            .frame(width: popoverSize.width, height: popoverSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(1)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke()
                    .foregroundStyle(.red.opacity(0.15))
            }
    }
    .padding()
    .background(Colors.canvasBackground.color)
    // .background(.orange.opacity(0.2))
}

#Preview("popover") {
    VStack {
        PreviewRepresentable()
    }
}

#endif
