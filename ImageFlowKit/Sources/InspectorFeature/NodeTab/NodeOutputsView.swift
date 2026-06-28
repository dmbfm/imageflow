import Combine
import ComponentKit
import Helpers
import SharedModels
import XKit

final class NodeOutputsView: XView, Rx, WithRef {
    var vm: NodeOutputsViewModel

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

    var nodeOutputViews: [NodeOutputView] = []

    var cancellables: Set<AnyCancellable> = []

    init(_ vm: NodeOutputsViewModel) {
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
        self.labelView.rx(self.vm.$title, kp: \.text)
        self.vm.$outputs.sink { [weak self] _ in self?.outputsDidChange() }.store(in: &self.cancellables)
    }

    func outputsDidChange() {
        for index in 0..<(min(self.vm.outputs.count, self.nodeOutputViews.count)) {
            if self.nodeOutputViews[index].vm !== self.vm.outputs[index] {
                logger.error("self.nodeOutputsView[index].vm !== inputs[index]: this should not happe! Reloading")
                self.reloadOutputs()
            }
        }

        if self.vm.outputs.count > self.nodeOutputViews.count {
            for index in self.nodeOutputViews.count..<self.vm.outputs.count {
                self.nodeOutputViewAdd(self.vm.outputs[index])
            }
        } else if self.vm.outputs.count < self.nodeOutputViews.count {
            self.nodeOutputViewRemove(atOffsets: .init(integersIn: self.vm.outputs.count..<self.nodeOutputViews.count))
        }

    }

    func reloadOutputs() {
        logger.warning("reloadOutputs")
        self.nodeOutputViewRemoveAll()
        for output in self.vm.outputs {
            self.nodeOutputViewAdd(output)
        }
    }

    func nodeOutputViewAdd(_ vm: NodeOutputViewModel) {
        let view = NodeOutputView(vm)
        self.stackView.addView(view)
        self.nodeOutputViews.append(view)
    }

    func nodeOutputViewRemove(atOffsets indices: IndexSet) {
        for index in indices {
            self.nodeOutputViews[index].removeFromSuperview()
        }
        self.nodeOutputViews.remove(atOffsets: indices)
    }

    func nodeOutputViewRemove(at index: Int) {
        if let view = self.nodeOutputViews[tryGetAt: index] {
            view.removeFromSuperview()
            self.nodeOutputViews.remove(at: index)
        }
    }

    func nodeOutputViewRemoveAll() {
        for view in self.nodeOutputViews {
            view.removeFromSuperview()
        }
        self.nodeOutputViews.removeAll()
    }
}
