import Combine
import Helpers
import XKit

fileprivate protocol PickerInnerView: NSControl {
    var selectedIndex: Int { get set }
}

extension NSPopUpButton: PickerInnerView {
    var selectedIndex: Int {
        get {
            self.indexOfSelectedItem
        }
        set {
            self.selectItem(at: newValue)
        }
    }
}
extension NSSegmentedControl: PickerInnerView {
    var selectedIndex: Int {
        get {
            self.selectedSegment
        }
        set {
            self.selectedSegment = newValue
        }
    }
}

public final class PickerV2: XView, WithRef {
    public var selected: Int {
        didSet {
            if self.selected != oldValue {
                self.update()
            }
        }
    }

    public var onChange: ((Int) -> ())?

    public struct Option {
        var label: String
        var symbolName: String?

        public init(label: String, symbolName: String? = nil) {
            self.label = label
            self.symbolName = symbolName
        }
    }

    public enum Style {
        case menu(MenuStyle)
        case segmented

        public enum MenuStyle {
            case bordered
            case plain
        }
    }

    private var style: Style

    private var inner: (any PickerInnerView)!

    public override var intrinsicContentSize: NSSize {
        self.inner.intrinsicContentSize
    }

    private func makeInnerView(_ options: [Option]) -> any PickerInnerView {
        switch self.style {
        case .menu(let style):
            let view = NSPopUpButton()
            view.target = self
            view.action = #selector(Self.handler)
            view.font = .preferredFont(forTextStyle: .body)
            view.translatesAutoresizingMaskIntoConstraints = false
            // view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            // view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            view.isBordered = style == .bordered
            for option in options {
                view.addItem(withTitle: option.label)
                if let s = option.symbolName,
                    let image = XImage(systemSymbolName: s, accessibilityDescription: nil),
                    let item = view.itemArray[tryGetAt: view.itemArray.count - 1]
                {
                    item.image = image
                }
            }
            view.selectedIndex = self.selected
            return view
        case .segmented:
            let view = NSSegmentedControl(
                labels: options.map({ $0.label }),
                trackingMode: .selectOne,
                target: self,
                action: #selector(Self.handler)
            )
            for (index, option) in options.enumerated() {
                if let s = option.symbolName,
                    let image = XImage(systemSymbolName: s, accessibilityDescription: nil)
                {
                    view.setImage(image, forSegment: index)
                }
                view.translatesAutoresizingMaskIntoConstraints = false
                // view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
                // view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            }
            view.selectedIndex = self.selected
            return view
        }
    }

    public init(_ options: [Option], selected: Int, style: Style = .menu(.bordered)) {
        self.style = style
        self.selected = selected

        super.init(frame: .zero)

        self.inner = self.makeInnerView(options)

        self.addSubview(self.inner)
        self.inner.constraintToFillSuperview()

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setContentCompressionResistancePriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) {
        super.setContentCompressionResistancePriority(priority, for: orientation)
        self.inner.setContentCompressionResistancePriority(priority, for: orientation)
    }

    public override func setContentHuggingPriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) {
        super.setContentHuggingPriority(priority, for: orientation)
        self.inner.setContentHuggingPriority(priority, for: orientation)
    }

    @objc func handler() {
        if self.selected != self.inner.selectedIndex {
            self.selected = self.inner.selectedIndex
            self.onChange?(self.selected)
        }
    }

    func update() {
        if self.inner.selectedIndex != self.selected {
            self.inner.selectedIndex = self.selected
        }
    }
}

#Preview {

    let options: [PickerV2.Option] = [
        .init(label: "First", symbolName: "1.square.fill"),
        .init(label: "Second", symbolName: "2.square.fill"),
        .init(label: "Third", symbolName: "3.square.fill"),
    ]

    VStack(views: [
        PickerV2(
            options,
            selected: 1,
            style: .menu(.bordered)
        )
        .with(\.onChange, { print("-> \($0)") }),
        PickerV2(
            options,
            selected: 1,
            style: .menu(.plain)
        )
        .with(\.onChange, { print("-> \($0)") }),
        PickerV2(
            options,
            selected: 1,
            style: .segmented
        )
        .with(\.onChange, { print("-> \($0)") }),
    ])
}
