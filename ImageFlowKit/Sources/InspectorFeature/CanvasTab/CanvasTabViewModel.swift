import Combine
import Helpers
import SharedModels

@MainActor
final class CanvasTabViewModel: RxEventHandler {
    @PublishedEx var nodeCount: Int = 0
    @PublishedEx var edgeCount: Int = 0
    @PublishedEx var viewportValues: [Double] = [1.0, 2.0, 3.0]

    let flow: Flow
    let context: InspectorContext
    var cancellables: Set<AnyCancellable> = []

    init(_ flow: Flow, _ context: any InspectorContext) {
        self.flow = flow
        self.context = context

        self.nodeCount = self.flow.nodeCount
        self.edgeCount = self.flow.edgeCount

        self.rx(self.flow.$nodeCount, kp: \.nodeCount)
        self.rx(self.flow.$edgeCount, kp: \.edgeCount)
        if let coordinator = context.coordinator {
            self.rx(
                coordinator.canvasViewportPublisher.map({ [$0.origin.x, $0.origin.y, $0.scale] }),
                kp: \.viewportValues
            )
        }
    }

    enum Event {
        case viewportOrigin(Double, Double)
        case viewportScale(Double)
        case viewportRestore
        case createBookmark
    }

    func receive(event: Event) {
        switch event {
        case .viewportRestore:
            self.context.coordinator?.perform(userAction: .setCanvasViewPort(.init(origin: .zero, scale: 1.0)))
        case let .viewportOrigin(x, y):
            self.context.coordinator?.perform(userAction: .viewport(.setOrigin(.init(x: x, y: y))))
        case .viewportScale(let scale):
            self.context.coordinator?.perform(userAction: .viewport(.setZoom(scale, anim: false)))
        case .createBookmark:
            self.context.coordinator?.perform(userAction: .createBookmark)
        }
    }
}
