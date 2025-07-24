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
        #if os(macOS)
            .overlay {

            }
        #endif
        .frame(width: self.outerSize, height: self.outerSize)
    }
}

#if os(macOS)
    import AppKit
    struct FrameTrackingView: NSViewRepresentable {

        func makeNSView(context: Context) -> some NSView {
            Inner()
        }

        func updateNSView(_ nsView: NSViewType, context: Context) {
        
        }

        class Inner: NSView {
            override var isFlipped: Bool { true }

            override init(frame frameRect: NSRect) {
                super.init(frame: frameRect)

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(frameDidChange(_:)),
                    name: NSView.frameDidChangeNotification,
                    object: self
                )
            }

            override func hitTest(_ point: NSPoint) -> NSView? {
                nil
            }

            @objc
            func frameDidChange(_ notification: Notification) {
                print("Frame did change!")
            }

            required init?(coder: NSCoder) {
                nil
            }
        }
    }
#endif

#Preview {
    HStack {
        PortView(connected: false)
        PortView(connected: true)
    }
    .padding(50)
    .background(.white)
}
