import Combine
import ComponentKit
import Helpers
import XKit

final class NodeTypeView: XView, Rx, WithRef {

    @PublishedEx var name: String = "Type" {
        didSet {
            if self.name != oldValue {
                self.update()
            }
        }
    }

    var options: [String] = [] {
        didSet {
            if self.options != oldValue {
                self.update()
            }
        }
    }

    var selected: Int {
        get { self.pickerView.selected }
        set { self.pickerView.selected = newValue }
    }

    var selectedIndexPublisher: AnyPublisher<Int, Never> {
        self.pickerView.$selected.eraseToAnyPublisher()
    }

    var cancellables: Set<AnyCancellable> = []

    lazy var stackView: HStack = {
        HStack(views: [
            Label("Node Type"),
            Spacer(),
            self.simpleLabelView,
            self.pickerView,
        ])
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var simpleLabelView: Label = {
        Label(self.name)
    }()

    lazy var pickerView: Picker = {
        Picker([], selected: 0) { [weak self] index in
            guard let self else { return }
            if self.options.indices.contains(index) {
                self.name = self.options[index]
            }
        }
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()

        self.update()
    }

    func update() {
        if self.options.count < 2 {
            self.pickerView.isHidden = true
            self.simpleLabelView.isHidden = false
            self.simpleLabelView.text = self.name
        } else {
            self.simpleLabelView.isHidden = true
            self.pickerView.isHidden = false
            self.pickerView.options = self.options
            if let index = self.options.firstIndex(of: self.name) {
                self.pickerView.selected = index
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    NodeTypeView()
        .with(\.name, "Float")
        .constrainingWidth(toConstant: 300)
}

#Preview {
    NodeTypeView()
        .with(\.options, ["Float", "Int", "Vector 2", "Color"])
        .with(\.name, "Int")
        .constrainingWidth(toConstant: 300)
}
