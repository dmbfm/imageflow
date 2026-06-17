import Combine
import Helpers
import SharedModels
import XKit

@MainActor
final class NodeTabViewModel {

    @Published var state: State = .empty

    let contentViewModel: NodeTabContentViewModel

    var cancellables: Set<AnyCancellable> = []
    let flow: Flow

    init(_ flow: Flow) {
        self.flow = flow
        self.contentViewModel = .init(flow)
        flow.selectionDidChangePublisher.sink { [weak self] in
            guard let self else { return }
            if self.flow.selection.isEmpty {
                self.state = .empty
            } else {
                self.state = .nodeSelected
            }
        }.store(in: &self.cancellables)
    }

    enum State {
        case empty
        case nodeSelected
    }
}
