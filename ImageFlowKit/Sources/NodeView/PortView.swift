import CanvasView
import Design
import Logging
import Models
import SwiftUI

extension EnvironmentValues {
    @Entry var onPortPositionChanged: ((CGPoint) -> ())? = nil
}

extension View {
    func onPortPositionChanged(_ action: @escaping (CGPoint) -> ()) -> some View {
        self.environment(\.onPortPositionChanged, action)
    }
}

struct PortView: View, Equatable {

    static nonisolated func == (lhs: PortView, rhs: PortView) -> Bool {
        MainActor.assumeIsolated {
            lhs.connected == rhs.connected
        }
    }

    let connected: Bool
    let port: PortLocation
    var size: CGFloat = 4
    var outerSize: CGFloat = 12
    @Environment(\.onPortPositionChanged) var onPortPositionChanged
    @Environment(\.portDragGesture) var portDragGesture
    @State var isDragging: Bool = false

    internal init(
        connected: Bool,
        port: PortLocation = .init(node: .init(), port: .input(0)),
        size: CGFloat = 4,
        outerSize: CGFloat = 12,
    ) {
        self.connected = connected
        self.size = size
        self.outerSize = outerSize
        self.port = port
    }

    public var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            Circle()
                .fill(self.connected ? Colors.portConnected.color : Colors.portEmpty.color)
                .frame(width: self.size, height: self.size)
        }
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.frame(in: .named(canvasCoordinateSpaceName))) {
                        let frame = proxy.frame(in: .named(canvasCoordinateSpaceName))
                        self.onPortPositionChanged?(frame.center)
                    }
            }
        }
        .frame(width: self.outerSize, height: self.outerSize)
        .gesture(
            DragGesture(coordinateSpace: .named(canvasCoordinateSpaceName)).onChanged { value in
                let phase = { () -> PortDragGesture.Phase in
                    if self.isDragging == false {
                        self.isDragging = true
                        return .started
                    } else {
                        return .changed
                    }
                }()

                self.portDragGesture?.handler(.init(port: self.port, location: value.location), phase)
            }

            .onEnded { value in
                self.isDragging = false
                self.portDragGesture?.handler(.init(port: self.port, location: value.location), .ended)
            }
        )
    }
}

#Preview {
    HStack {
        PortView(connected: false)
        PortView(connected: true)
    }
    .padding(50)
    .background(.white)
}
