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

    lazy var stackView: HStack = {
        HStack(views: [])
            .with(\.distribution, .fillEqually)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    var context: InspectorContext?

    struct ViewModel: Equatable {
        var value: String
        var options: [String]
    }

    lazy var valueLabel: Label = {
        let view = Label("")
        view.alignment = .right
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()

    lazy var valuePicker: NSPopUpButton = {
        let view = NSPopUpButton()
        view.target = self
        view.action = #selector(Self.pickerHandler)
        view.font = .preferredFont(forTextStyle: .body)
        view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()

        // self.stackView.addView(self.label)
        self.update()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pickerHandler() {
        if let value = self.valuePicker.selectedItem?.title {
            self.context?.onNodeTypePickItem?(value)
        }
    }

    func update() {
        if self.vm.options.count > 1 {
            if self.valueLabel.superview != nil {
                self.valueLabel.removeFromSuperview()
            }
            if self.valuePicker.superview == nil {
                self.stackView.addView(self.valuePicker)
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
                self.stackView.addView(self.valueLabel)
            }

            if self.valueLabel.text != self.vm.value {
                self.valueLabel.text = self.vm.value
            }
        }
    }
}

#Preview {
    NodeTypeRowView()
        .constrainingWidth(toConstant: 320)
}
