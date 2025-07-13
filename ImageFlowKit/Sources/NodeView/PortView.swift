import Design
import SwiftUI

struct PortView: View, Equatable {
    let connected: Bool
    var size: CGFloat = 4
    var outerSize: CGFloat = 12

    public var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            Circle()
                .fill(self.connected ? Colors.portConnected.color : Colors.portEmpty.color)
                .frame(width: self.size, height: self.size)
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
