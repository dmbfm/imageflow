import Combine
import ComponentKit
import Helpers
import SharedModels
import XKit

final class BookmarkListView: XView, Rx {
    let vm: BookmarkListViewModel

    lazy var listView: List = {
        List(views: [], wrapInScrollView: false)
            .with(\.rowHeight, .intrinsicSize(constant: 0))
            .with(\.reversed, true)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    var cancellables: Set<AnyCancellable> = []

    init(_ vm: BookmarkListViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.addSubview(self.listView)
        self.listView.constraintToFillSuperview()

        self.vm.$items.sink { [weak self] _ in
            self?.update()
        }.store(in: &self.cancellables)

        self.listView.rx(self.vm.$selectedIndex, kp: \.selectedIndex)
        self.vm.handleEvents(from: self.listView.$selectedIndex.map({ .selectedIndex($0) }))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        for i in 0..<(min(self.listView.views.count, self.vm.items.count)) {
            let item = self.vm.items[i]
            if let view = self.listView.views[i] as? BookmarkListItemView {
                view.item = item
            }
        }

        if self.vm.items.count > self.listView.views.count {
            for i in (self.listView.views.count)..<self.vm.items.count {
                let item = self.vm.items[i]
                self.listView.addView(
                    BookmarkListItemView(item) { [weak self] id in
                        self?.vm.delete(id)
                    } onRename: { [weak self] id, newName in
                        self?.vm.rename(id, newName)
                    }
                )
            }
        } else if self.listView.views.count > self.vm.items.count {
            self.listView.removeViews(atOffsets: .init(integersIn: self.vm.items.count..<self.listView.views.count))
        }
    }
}

final class BookmarkListItemView: XView {
    var item: Item {
        didSet {
            if self.item.name != oldValue.name {
                self.labelView.text = item.name
            }

            if self.item.position != oldValue.position || self.item.scale != oldValue.scale {
                let x = item.position.x.formatted(self.formatter)
                let y = item.position.y.formatted(self.formatter)
                let s = item.scale.roundTo(fractionalDigits: 2).formatted(FloatingPointFormatStyle<Double>.Percent())
                self.infoView.text =
                    "(\(x), \(y)) • \(s)"
            }
        }
    }

    var onDeleteClick: (UUID) -> ()
    var onRename: (UUID, String) -> ()

    lazy var hstackView: HStack = {
        HStack(
            alignment: .center,
            spacing: 10,
            views: [
                Spacer().constrainingWidth(toConstant: 4),
                self.labelView,
                Spacer(),
                self.infoView,
                Spacer().constrainingWidth(toConstant: 4),
            ]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var labelView: XTextField = {
        let view = XTextField(labelWithString: item.name)
        view.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        return view
    }()

    var formatter: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }

    lazy var infoView: Label = {
        Label(
            "(\(item.position.x.formatted(self.formatter)), \(item.position.x.formatted(self.formatter))) • \(item.scale.roundTo(fractionalDigits: 2).formatted(FloatingPointFormatStyle<Double>.Percent()))"
        )
        .with(\.font, .systemFont(ofSize: NSFont.systemFontSize - 4, weight: .regular))
        .with(\.textColor, .system.secondaryLabel)
    }()

    override func hitTest(_ point: NSPoint) -> NSView? {
        if self.window?.currentEvent?.type == .rightMouseDown {
            self.frame.contains(point) ? self : nil
        } else {
            nil
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu(title: "Bookmark")

        let renameItem = MenuItem(title: "Rename", action: nil, keyEquivalent: "")
            .with(\.id, self.item.id)
            .with(\.target, self)
            .with(\.action, #selector(Self.rename))

        let deleteItem = MenuItem(title: "Delete", action: nil, keyEquivalent: "")
            .with(\.id, self.item.id)
            .with(\.target, self)
            .with(\.action, #selector(Self.delete(_:)))

        menu.items = [
            .sectionHeader(title: self.item.name),
            renameItem, deleteItem,
        ]

        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    final class MenuItem: NSMenuItem, WithRef {
        var id: UUID = .init()
    }

    @objc func rename() {
        logger.info("rename!")
        self.labelView.isEditable = true
        self.labelView.isSelectable = true
        self.labelView.becomeFirstResponder()
        self.labelView.delegate = self
    }

    @objc func delete(_ sender: MenuItem) {
        self.onDeleteClick(self.item.id)
    }

    init(_ item: Item, onDeleteClick: @escaping (UUID) -> (), onRename: @escaping (UUID, String) -> ()) {
        self.item = item
        self.onDeleteClick = onDeleteClick
        self.onRename = onRename

        super.init(frame: .zero)

        self.addSubview(self.hstackView)
        self.hstackView.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BookmarkListItemView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        self.labelView.isEditable = false
        self.labelView.isSelectable = false
        self.onRename(self.item.id, self.labelView.text)
    }
}

#Preview {
    BookmarkListItemView(
        .init(
            id: .init(),
            name: "Bookmark 1",
            position: .init(x: 2, y: 4),
            scale: 1
        )
    ) { _ in
    } onRename: { _, _ in
    }
}
