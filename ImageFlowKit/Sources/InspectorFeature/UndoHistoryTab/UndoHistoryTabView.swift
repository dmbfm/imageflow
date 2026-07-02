import Combine
import ComponentKit
import Helpers
import XKit

final class UndoHistoryTabView: XView, WithRef, Rx {

    let vm: UndoHistoryTabViewModel

    var cancellables: Set<AnyCancellable> = []

    var selectedIndex: Int? {
        self.tableView.selectedRowIndexes.first
    }

    lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: 8,
            views: [
                self.titleView,
                self.scrollView,
                Spacer().constrainingHeight(toConstant: 6),
            ]
        )
    }()

    lazy var titleView: Padded<Label> = {
        Padded(
            Label(
                "Undo History",
                font: .preferredFont(forTextStyle: .headline),
                alignment: .left
            )
            .with(\.translatesAutoresizingMaskIntoConstraints, false),
            insets: .init(top: 0, left: 6, bottom: 0, right: 0)
        )
    }()

    lazy var scrollView: NSScrollView = {
        class ClipView: NSClipView { override var isFlipped: Bool { true } }
        let view = NSScrollView()
        view.contentView = ClipView()
        view.hasVerticalScroller = true
        view.documentView = self.tableView
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        view.drawsBackground = false
        return view
    }()

    lazy var tableView: TableView = {
        let view = TableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let column = NSTableColumn(identifier: .undoHistoryItem)
        view.addTableColumn(column)
        view.dataSource = self
        view.delegate = self
        view.headerView = nil
        view.backgroundColor = .clear
        view.allowsMultipleSelection = false
        view.allowsEmptySelection = true
        return view
    }()

    init(_ vm: UndoHistoryTabViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.setupView()

        self.tableView.reloadData()

        self.setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()
    }

    func setupBindings() {
        self.vm.$items.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &self.cancellables)

        self.vm.$selected.sink { [weak self] _ in
            self?.updateSelected()
        }.store(in: &self.cancellables)
    }

    func updateSelected() {
        if let index = self.vm.selectedIndex, index != self.selectedIndex {
            self.tableView.selectRowIndexes(.init(integer: index), byExtendingSelection: false)
            self.tableView.scrollRowToVisible(index)
        }
    }
}

extension UndoHistoryTabView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        self.vm.items.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let item = self.vm.items[tryGetAt: row],
            let view = tableView.makeView(withIdentifier: .undoHistoryItem, owner: tableView.delegate),
            let rowView = view as? ItemView
        {
            rowView.identifier = .undoHistoryItem
            rowView.item = item
            rowView.dimmed = row > self.vm.selectedIndex ?? .max
            return rowView
        } else {
            return nil
        }
    }
}

extension UndoHistoryTabView: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.selectedIndex == nil {
            self.updateSelected()
            return
        }
        self.tableView.enumerateAvailableRowViews { view, row in
            if let view = view.view(atColumn: 0) as? ItemView {
                view.dimmed = self.selectedIndex.map({ row > $0 }) ?? false
            }
        }
        self.vm.receive(event: .select(self.selectedIndex))
    }
}

extension UndoHistoryTabView {
    class ItemView: XView {
        var item: UndoHistoryTabViewModel.Item {
            didSet {
                if self.item != oldValue {
                    self.updateItem()
                }
            }
        }
        var dimmed: Bool = false {
            didSet {
                if self.dimmed != oldValue {
                    self.updateDimmed()
                }
            }
        }

        lazy var stackView: HStack = {
            HStack(
                alignment: .center,
                spacing: 4,
                views: [
                    self.iconView,
                    self.labelView,
                ]
            )
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
        }()

        lazy var labelView: Label = {
            Label("Undo \(item.id)")
        }()

        lazy var iconView: Icon = {
            Icon(systemName: "paintbrush.pointed.fill")
                .with(\.color, self.dimmed ? .monochrome(.system.secondaryLabel) : .monochrome(nil))
        }()

        init(_ item: UndoHistoryTabViewModel.Item) {
            self.item = item

            super.init(frame: .zero)

            self.addSubview(self.stackView)
            self.stackView.constraintToFillSuperview()

            self.updateDimmed()
            self.updateItem()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func updateDimmed() {
            self.labelView.textColor = self.dimmed ? .system.tertiaryLabel : .system.label
            self.iconView.color = self.dimmed ? .monochrome(.system.quaternaryLabel) : .monochrome(nil)
        }

        func updateItem(_ oldValue: UndoHistoryTabViewModel.Item? = nil) {
            self.labelView.text = item.title

            if oldValue?.icon != self.item.icon {
                self.iconView.systemName = self.item.icon
            }
        }
    }
}

extension UndoHistoryTabView {
    class TableView: NSTableView {
        override func makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
            let view = super.makeView(withIdentifier: identifier, owner: owner)
            if identifier == .undoHistoryItem {
                let view = (view as? ItemView) ?? ItemView(.init(id: 0, title: "", icon: "xmark"))
                view.item = .init(id: 0, title: "", icon: "xmark")
                view.dimmed = false
                return view
            }
            return view
        }
    }
}

fileprivate extension NSUserInterfaceItemIdentifier {
    static let undoHistoryItem: Self = .init("com.dmbfm.imageflow.undo-history-item")
}
