import CanvasView
import SharedModels

extension CanvasView.Viewport {
    init(_ model: CanvasViewportModel) {
        self.init(origin: model.origin, scale: model.scale)
    }

    func into() -> CanvasViewportModel {
        .init(origin: self.origin, scale: self.scale)
    }
}
