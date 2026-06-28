import Combine
import ComponentKit
import Helpers
import SharedModels
import XKit

final class NodeOutputView: XView, Rx, WithRef {
    var cancellables: Set<AnyCancellable> = []
    var vm: NodeOutputViewModel

    lazy var boxView: ComponentKit::Box = {
        Box(inspectorBlockWithView: self.titleView)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var titleView: PropertyTitleView = {
        PropertyTitleView(self.vm.name, connected: self.vm.connected, hasChanges: false, type: self.vm.type)
    }()

    init(_ vm: NodeOutputViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.addSubview(self.boxView)
        self.boxView.constraintToFillSuperview()

        self.titleView.rx(self.vm.$name, kp: \.label)
        self.titleView.rx(self.vm.$connected.map({ .some($0) }), kp: \.connected)
        self.titleView.rx(self.vm.$type.map({ .some($0) }), kp: \.type)

        self.titleView.portButtonView.publisher.map({ .portButtonClicked }).sendEvents(to: self.vm)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
