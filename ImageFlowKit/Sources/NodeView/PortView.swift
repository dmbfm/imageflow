import Design
import Logging
import SwiftUI
import CanvasView

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
    var size: CGFloat = 4
    var outerSize: CGFloat = 12
    @Environment(\.onPortPositionChanged) var onPortPositionChanged

    internal init(
        connected: Bool,
        size: CGFloat = 4,
        outerSize: CGFloat = 12,
    ) {
        self.connected = connected
        self.size = size
        self.outerSize = outerSize
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
