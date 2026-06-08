import SharedModels
import SwiftUI
import XKit

final class CanvasInspectorController: XViewController {

    let flow: Flow

    var contentView: CanvasInspectorView!

    init(_ flow: Flow) {
        self.flow = flow
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
    }
}

fileprivate struct PreviewView: XViewRepresentable {

    func makeView(context: Context) -> some NSView {
        context.coordinator.controller = .init(.init())
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
