import CanvasView
import CommonUtils
import SwiftUI

// public struct EdgeView: View, Equatable {

//     let edge: Edge

//     public struct Edge: Sendable, Equatable {
//         var start: CGPoint
//         var end: CGPoint
//         var color: Color

//         public init(start: CGPoint, end: CGPoint, color: Color) {
//             self.start = start
//             self.end = end
//             self.color = color
//         }
//     }

//     public init(edge: EdgeView.Edge) {
//         self.edge = edge
//     }

//     public var body: some View {
//         Path { path in
//             let start = self.edge.start
//             let end = self.edge.end
//             let dist1 = min(30.0, abs(start.x - end.x) * 0.32 + abs(start.y - end.y) * 0.1)
//             let cp1 = start + CGPoint(x: dist1 * 0.95, y: 0.0)
//             let cp2 = start + CGPoint(x: dist1, y: 0.0)
//             let cp3 = end - CGPoint(x: dist1, y: 0.0)
//             let cp4 = end - CGPoint(x: dist1 * 0.95, y: 0.0)
//             let middle = cp2 * 0.5 + cp3 * 0.5

//             path.move(to: start)
//             path.addCurve(to: middle, control1: cp1, control2: cp2)
//             path.move(to: end)
//             path.addCurve(to: middle, control1: cp3, control2: cp4)
//         }
//         .stroke(self.edge.color, style: .init(lineWidth: 4, lineCap: .round))
//         .animation(.easeInOut(duration: 0.08), value: self.edge.color)
//     }
// }

// #Preview {
//     @Previewable @State var viewport = CanvasViewport()
//     @Previewable @State var color: Color = .teal
//     VStack {
//         CanvasView(viewport: $viewport) {
//             EdgeView(edge: .init(start: .zero, end: .init(x: 250, y: 250), color: color))
//         }
//         Button("Randomize color") {
//             color = .random()
//         }
//     }
//     .frame(width: 500, height: 500)
// }
