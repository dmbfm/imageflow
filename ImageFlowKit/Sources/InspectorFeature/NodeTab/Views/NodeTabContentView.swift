import Combine
import ComponentKit
import Helpers
import SharedModels
import XKit

final class NodeTabContentView: XView, Rx, WithRef {

    var vm: NodeTabContentViewModel

    var cancellables: Set<AnyCancellable> = []

    init(_ vm: NodeTabContentViewModel) {
        self.vm = vm
        super.init(frame: .zero)

        self.withLayer({ $0.backgroundColor = .red })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
