import Combine
import Helpers
import XKit

public final class Picker: XView, Rx, WithRef {

    public var options: [String] {
        didSet {
            if self.options != oldValue {
                self.update()
            }
        }
    }

    @Published
    public var selected: Int {
        didSet {
            if self.selected != oldValue {
                self.update()
                self.onChange?(self.selected)
            }
        }
    }

    public var onChange: ((Int) -> ())?

    lazy var inner: NSPopUpButton = {
        let view = NSPopUpButton()
        view.target = self
        view.action = #selector(Self.handler)
        view.font = .preferredFont(forTextStyle: .body)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return view
    }()

    public var cancellables: Set<AnyCancellable> = []

    public init(_ options: [String], selected: Int, onChange: ((Int) -> ())? = nil) {
        self.options = options
        self.selected = selected
        self.onChange = onChange

        super.init(frame: .zero)

        self.addSubview(self.inner)
        self.inner.constraintToFillSuperview()

        self.update()
    }

    func update() {
        let needsRepopulateOptions: Bool = {
            var countChanged: Bool { self.options.count != self.inner.itemArray.count }
            var different: Bool {
                for (index, item) in self.inner.itemArray.enumerated() {
                    if self.options.indices.contains(index) {
                        if self.options[index] != item.title {
                            return true
                        }
                    } else {
                        return true
                    }
                }
                return false
            }
            return countChanged || different
        }()

        if needsRepopulateOptions {
            self.repopulateOptions()
        }

        if self.selected != self.inner.indexOfSelectedItem {
            self.inner.selectItem(at: self.selected)
        }
    }

    func repopulateOptions() {
        self.inner.removeAllItems()
        self.inner.addItems(withTitles: self.options)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handler() {
        self.selected = self.inner.indexOfSelectedItem
    }
}

#Preview {
    Picker(["First", "Second", "Third"], selected: 1) { print("selected: \($0)") }
}

#Preview {
    Picker([], selected: 0) { print("selected: \($0)") }
}
