import SwiftUI
import TextInput
import Values
import XKit

class NodeMatrixInputControlView: BaseNodeInputControlView, MultiRowNodeInputControlView {

    let spacing: CGFloat = 4

    lazy var controlView: XView = {
        let view = XView()
        return view
    }()

    var multirowMixin: MultiRowNodeInputControlViewMixin!

    var numberInputs: [NumberInputController] = []

    var dragConfiguration: NumberInputController.DragConfiguration {
        .free(.init(sensitivity: .init(), fractionalDigits: 2))
    }

    var dim: Int {
        switch self.value.type {
        case .matrix2x2: 2
        case .matrix3x3: 3
        case .matrix5x5: 5
        case .matrix7x7: 7
        default: 1
        }
    }

    func doubleValue(_ index: Int) -> Double {
        self.doubleValue(row: index % self.dim, col: index / self.dim)
    }

    func doubleValue(row: Int, col: Int) -> Double {
        switch self.value {
        case .matrix2x2(let mat):
            mat[row, col]
        case .matrix3x3(let mat):
            mat[row, col]
        case .matrix5x5(let mat):
            mat[row, col]
        case .matrix7x7(let mat):
            mat[row, col]
        default: 0
        }
    }

    func value(settingIndex index: Int, to val: Double) -> Value {
        self.value(settingRow: index % self.dim, column: index / self.dim, to: val)
    }

    func value(settingRow row: Int, column col: Int, to val: Double) -> Value {
        switch self.value {
        case .matrix2x2(var mat):
            mat[row, col] = val
            return .matrix2x2(mat)
        case .matrix3x3(var mat):
            mat[row, col] = val
            return .matrix3x3(mat)
        case .matrix5x5(var mat):
            mat[row, col] = val
            return .matrix5x5(mat)
        case .matrix7x7(var mat):
            mat[row, col] = val
            return .matrix7x7(mat)
        default:
            return .matrix2x2(.identity)
        }
    }

    var cellCount: Int { self.dim * self.dim }

    func controllers(forColumn col: Int) -> [NumberInputController] {
        self.numberInputs.filter({ ($0.tag - col) % self.dim == 0 })
    }

    override init(label: String, value: Value, connected: Bool = false) {
        super.init(label: label, value: value, connected: connected)

        self.multirowMixin = .init(self)

        self.numberInputs = (0..<self.cellCount).map({ index in
            let c = NumberInputController()
            c.view.setContentCompressionResistancePriority(.defaultLow - 10, for: .horizontal)
            c.view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
            c.tag = index
            c.delegate = self
            c.value = self.doubleValue(index)
            c.dragConfiguration = self.dragConfiguration
            return c
        })

        var anchor = self.controlView.leadingAnchor
        for col in 0..<self.dim {

            let controllers = self.controllers(forColumn: col)
            let stack = XStackView(views: controllers.map({ $0.view }))
            stack.orientation = .vertical
            stack.distribution = .equalCentering
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.spacing = self.spacing

            self.controlView.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.widthAnchor.constraint(
                    equalTo: self.controlView.widthAnchor,
                    multiplier: 1.0 / Double(self.dim),
                    constant: -spacing * Double(self.dim - 1) / Double(self.dim)
                ),
                stack.leadingAnchor.constraint(equalTo: anchor, constant: col == 0 ? 0 : self.spacing),
                stack.topAnchor.constraint(equalTo: self.controlView.topAnchor),
                stack.bottomAnchor.constraint(equalTo: self.controlView.bottomAnchor),
            ])
            anchor = stack.trailingAnchor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        for (index, c) in self.numberInputs.enumerated() {
            c.value = self.doubleValue(index)
        }
    }
}

extension NodeMatrixInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        let index = numberInput.tag
        let newValue = self.value(settingIndex: index, to: change.newValue)
        let oldValue = self.value(settingIndex: index, to: change.oldValue)
        self.setValue(newValue: newValue, oldValue: oldValue, commit: change.commit)
    }

    func numberInputRespondsToInsertTab(_ numberInput: NumberInputController) -> Bool {
        true
    }

    func numberInputDidInsertTab(_ numberInput: NumberInputController) {
        let nextIndex = (numberInput.tag + 1) % self.cellCount
        guard let next = self.numberInputs[tryGetAt: nextIndex] else { return }
        numberInput.isEditable = false
        next.isEditable = true
        Task(priority: .medium) {
            self.window?.makeFirstResponder(next.view.theTextField)
        }
    }
}
