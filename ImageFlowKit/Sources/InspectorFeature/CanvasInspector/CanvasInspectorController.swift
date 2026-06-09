import Combine
import SharedModels
import SwiftUI
import XKit

final class CanvasInspectorController: XViewController {

    let flow: Flow
    let coordinator: GlobalCoordinator

    var contentView: CanvasInspectorView!
    var cancellables: Set<AnyCancellable> = []

    init(_ flow: Flow, _ coordinator: GlobalCoordinator) {
        self.flow = flow
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CanvasInspectorView()

        self.view = view
        self.contentView = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.coordinator.canvasViewportPublisher.sink { viewport in
            self.contentView.vm.viewport = viewport
        }.store(in: &self.cancellables)

        self.contentView.positionRowView.delegate = self
        self.contentView.zoomRowView.delegate = self
    }
}

extension CanvasInspectorController: NodeInputControlDelegate {
    func nodeInputControl(_ sender: any NodeInputControlView, valueDidChange change: ValueChange) {
        if sender == self.contentView.positionRowView {
            let v = change.newValue.vector2
            self.coordinator.perform(
                userAction: .setCanvasViewPort(
                    .init(origin: .init(x: v.x, y: v.y), scale: self.contentView.vm.viewport.scale)
                )
            )
        } else if sender == self.contentView.zoomRowView {
            let scale = change.newValue.float
            self.coordinator.perform(userAction: .viewport(.setZoom(scale, anim: false)))
            // self.coordinator.perform(
            //     userAction: .setCanvasViewPort(
            //         .init(origin: self.contentView.vm.viewport.origin, scale: scale)
            //     )
            // )
        }
    }

    func nodeInputControl(_ sender: any NodeInputControlView, displayNameForAsset: UUID) -> String? {
        nil
    }

    func nodeInputControlPortButtonClicked(_ sender: any NodeInputControlView) {

    }

    func nodeInputControlRestoreButtonClicked(_ sender: any NodeInputControlView) {

    }

    func nodeInputControlOpenAssetPicker(_ sender: any NodeInputControlView) {

    }
}

fileprivate struct PreviewView: XViewRepresentable {

    func makeView(context: Context) -> some NSView {
        context.coordinator.controller = .init(.init(), .init(MockGlobalCoordinator()))
        return context.coordinator.controller.view
    }

    func updateView(_ view: ViewType, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    class Coordinator {
        var controller: CanvasInspectorController!
    }
}

#Preview {
    VStack {
        PreviewView()
            .frame(width: 320)
            .border(.red.opacity(0.08))
            .padding()
    }
}
