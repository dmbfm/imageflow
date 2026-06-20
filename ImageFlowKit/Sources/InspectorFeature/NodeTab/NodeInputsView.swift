import Combine
import ComponentKit
import Helpers
import XKit

final class NodeInputsView: XView, Rx, WithRef {

    var vm: NodeInputsViewModel

    lazy var labelView: Label = {
        Label(self.vm.title)
            .with(\.font, .systemFont(ofSize: XFont.systemFontSize, weight: .bold))
    }()

    lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: 8,
            views: [self.labelView]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    var nodeInputViews: [NodeInputView] = []

    var cancellables: Set<AnyCancellable> = []

    init(_ vm: NodeInputsViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()

        self.setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupBindings() {
        self.labelView.rx(self.vm.$title.map({ $0.isEmpty }), kp: \.isHidden)
        self.vm.$inputs.sink { [unowned self] inputs in
            self.inputsDidChange(inputs)
            self.stackView.isHidden = self.nodeInputViews.isEmpty
        }.store(in: &self.cancellables)
    }

    func inputsDidChange(_ inputs: [NodeInputViewModel]) {
        for index in 0..<(min(inputs.count, self.nodeInputViews.count)) {
            if self.nodeInputViews[index].vm !== inputs[index] {
                logger.error("self.nodeInputViews[index].vm !== inputs[index]: this should not happe! Reloading")
                self.reloadInputs(inputs)
            }
        }

        if inputs.count > self.nodeInputViews.count {
            for index in self.nodeInputViews.count..<inputs.count {
                self.nodeInputViewAdd(inputs[index])
            }
        } else if inputs.count < self.nodeInputViews.count {
            self.nodeInputViewRemove(atOffsets: .init(integersIn: inputs.count..<self.nodeInputViews.count))
        }
    }

    func reloadInputs(_ inputs: [NodeInputViewModel]) {
        logger.warning("reloadInputs")
        self.nodeInputViewRemoveAll()
        for input in inputs {
            self.nodeInputViewAdd(input)
        }
    }

    // MARK: - NodeInputView management

    func nodeInputViewAdd(_ vm: NodeInputViewModel) {
        self.nodeInputViewAdd(.init(vm))
    }

    func nodeInputViewAdd(_ view: NodeInputView) {
        self.stackView.addView(view)
        self.nodeInputViews.append(view)
    }

    func nodeInputViewRemove(atOffsets indices: IndexSet) {
        for index in indices {
            self.nodeInputViews[index].removeFromSuperview()
        }
        self.nodeInputViews.remove(atOffsets: indices)
    }

    func nodeInputViewRemove(at index: Int) {
        if let view = self.nodeInputViews[tryGetAt: index] {
            view.removeFromSuperview()
            self.nodeInputViews.remove(at: index)
        }
    }

    func nodeInputViewRemoveAll() {
        for view in self.nodeInputViews {
            view.removeFromSuperview()
        }
        self.nodeInputViews.removeAll()
    }
}

#Preview {
    NodeInputsView(.init())
}

#Preview {
    NodeInputsView(
        .init()
            .with(\.title, "Options")
            .with(
                \.inputs,
                [
                    .init()
                        .with(\.name, "Is Enabled")
                        .with(\.value, .bool(true))
                ]
            )
    )
    .constrainingWidth(toConstant: 300)
}
