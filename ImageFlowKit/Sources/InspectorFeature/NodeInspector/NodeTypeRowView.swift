import ComponentKit
import SharedModels
import XKit

final class NodeTypeRowView: XView {

    var vm: ViewModel = .init(value: "Float Value", options: ["FloatValue"]) {
        didSet {
            if self.vm != oldValue {
                self.update()
            }
        }
    }

    lazy var boxView: Box = {
        let view = block(self.stackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: XStackView = {
        let stackView = XStackView()
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.distribution = .fillEqually
        return stackView
    }()

    var didPickItem: ((String) -> ())?

    struct ViewModel: Equatable {
        var value: String
        var options: [String]
    }

    lazy var label: XLabel = {
        let view = XLabel(labelWithString: "Node Type")
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .system.secondaryLabel
        view.lineBreakMode = .byTruncatingTail
        view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()

    lazy var valueLabel: XLabel = {
        let view = XLabel(labelWithString: "")
        view.alignment = .right
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()

    lazy var valuePicker: NSPopUpButton = {
        let view = NSPopUpButton()
        view.target = self
        view.action = #selector(Self.pickerHandler)
        view.font = .preferredFont(forTextStyle: .body)
        // view.controlSize = .small
        view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        // view.activeCompressionOptions = .reduceMetrics
        view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.boxView)
        self.boxView.constraintToFillSuperview()

        self.stackView.addArrangedSubview(self.label)
        self.update()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pickerHandler() {
        if let value = self.valuePicker.selectedItem?.title {
            self.didPickItem?(value)
        }
    }

    func update() {
        if self.vm.options.count > 1 {
            if self.valueLabel.superview != nil {
                self.valueLabel.removeFromSuperview()
            }
            if self.valuePicker.superview == nil {
                self.stackView.addView(self.valuePicker, in: .trailing)
            }

            self.valuePicker.removeAllItems()

            for item in self.vm.options {
                self.valuePicker.addItem(withTitle: item)
            }

            if let index = self.vm.options.firstIndex(of: self.vm.value) {
                self.valuePicker.selectItem(at: index)
            }

        } else {
            if self.valuePicker.superview != nil {
                self.valuePicker.removeFromSuperview()
            }
            if self.valueLabel.superview == nil {
                self.stackView.addView(self.valueLabel, in: .trailing)
            }

            if self.valueLabel.text != self.vm.value {
                self.valueLabel.text = self.vm.value
            }
        }
    }
}
