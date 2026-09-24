import Combine
import Helpers
import XKit

public final class List: XView, WithRef, Rx {

    @PublishedEx public var selectedIndex: Int? = nil {
        didSet {
            if self.selectedIndex != oldValue {
                if let index = self.selectedIndex {
                    let index = self.views.count - 1 - index
                    self.tableView.selectRowIndexes(.init(integer: index), byExtendingSelection: false)
                } else {
                    self.tableView.deselectAll(nil)
                }
            }
        }
    }

    public var rowHeight: RowHeight = .uniform {
        didSet {
            self.tableView.reloadData()
        }
    }

    public var reversed: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }

    public enum RowHeight {
        case uniform
        case fixed(CGFloat)
        case intrinsicSize(constant: CGFloat = 0.0)
    }

    public var cancellables: Set<AnyCancellable> = []

    lazy var scrollView: VScrollView = {
        VScrollView(views: [self.tableView])
    }()

    lazy var tableView: XTableView = {
        let view = XTableView()
        view.dataSource = self
        view.delegate = self
        view.wantsLayer = true
        // view.style = .plain.
        view.headerView = nil
        view.style = .plain
        view.gridStyleMask = .solidHorizontalGridLineMask
        view.gridColor = .system.quaternaryFill
        view.allowsMultipleSelection = false
        view.allowsEmptySelection = true

        view.focusRingType = .none
        view.backgroundColor = .system.secondaryFill
        view.withLayer({ $0.cornerRadius = 10 })
        view.intercellSpacing = .init(width: 0, height: 4)

        view.addTableColumn(.init())

        return view
    }()

    public var views: [XView] {
        didSet {
            self.tableView.reloadData()
        }
    }

    public init(views: [XView], wrapInScrollView: Bool = false) {
        self.views = views

        super.init(frame: .zero)

        if wrapInScrollView {
            self.scrollView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.scrollView)
            self.scrollView.constraintToFillSuperview()
        } else {
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.tableView)
            self.tableView.constraintToFillSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addView(_ view: XView) {
        self.views.append(view)
    }

    public func addView(_ view: XView, at index: Int) {
        self.views.insert(view, at: index)
    }

    public func removeView(_ view: XView) {
        if let index = self.views.firstIndex(of: view) {
            self.views.remove(at: index)
        }
    }

    public func removeViews(atOffsets set: IndexSet) {
        self.views.remove(atOffsets: set)
    }

    public func removeAllViews() {
        self.views.removeAll()
    }
}

extension List: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        self.views.count
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let index = self.reversed ? self.views.count - row - 1 : row
        guard let view = self.views[tryGetAt: index] else { return nil }

        return HStack(
            alignment: .center,
            spacing: 0,
            views: [
                view
            ]
        )
    }

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = TableRowView()
        view.isLast = row == (self.views.count - 1)
        return view
    }
}

extension List: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch self.rowHeight {
        case .uniform: Self.noIntrinsicMetric
        case .fixed(let height): height
        case .intrinsicSize(let c):
            if let height = self.views[tryGetAt: row]?.intrinsicContentSize.height {
                height + c
            } else {
                Self.noIntrinsicMetric
            }
        }
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        self.selectedIndex = self.tableView.selectedRowIndexes.first
            .map({ self.views.count - 1 - $0 })
    }
}

class TableRowView: NSTableRowView {
    var isLast: Bool = false
    override func drawSeparator(in dirtyRect: NSRect) {
        if !self.isLast {
            super.drawSeparator(in: dirtyRect)
        }
    }
}

#Preview {
    List(
        views: (0...100).map({
            Label("Row \($0)")
                .with(\.font, .systemFont(ofSize: 10 + .random(in: 0...10)))
        }),
        wrapInScrollView: true
    )
}
