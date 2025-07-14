import AppKit
import NodeControls
import SwiftUI

struct IntrospectView: NSViewRepresentable {
    func makeNSView(context: Context) -> Inner {
        Inner()
    }

    func updateNSView(_ nsView: Inner, context: Context) {
        nsView.run()
    }

    class Inner: NSView {

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.isHidden = true
        }

        required init?(coder: NSCoder) {
            nil
        }

        func run() {
            var superview = self.superview

            func printSubviews(_ prefix: String, _ view: NSView) {
                print(prefix + "\(view.className) - isTextField? \((view as? NSTextField) != nil )")

                if let textField = view as? NSTextField {
                    Task { @MainActor in
                        // try! await Task.sleep(for: .seconds(2))
                        textField.focusRingType = .none
                        textField.cell?.focusRingType = .none
                        // textField.clipsToBounds = true
                        textField.isBordered = false
                        // textField.isSelectable = false
                    }
                }

                for child in view.subviews {
                    printSubviews(prefix + " ", child)
                }
            }

            while superview != nil {
                print("superview: \(superview?.className)")
                superview = superview?.superview
                if let superview {
                    printSubviews(" ", superview)
                    // for view in superview.subviews {
                    //     print("  subview: \(view.className)")
                    // }
                }
            }
        }

        override func viewDidMoveToWindow() {
            self.run()
        }
    }
}

struct ContentView: View {
    @State var value: Double = 1.234
    @State var text = "Some Text"
    var body: some View {
        VStack {
            // NodeNumberInput(value: self.$value)
            // 	.padding(50)

            VStack {
                TextField("", text: self.$text)
                    .textFieldStyle(.plain)
                    .fixedSize()
                    .padding(.vertical, 4)
                    .padding(.leading, 4)
            }
            .background {
                Color.white
            }
            // .overlay {
            //     IntrospectView()
            // }
            // .focusEffectDisabled(true)
        }
    }
}

@main
struct Application: App {
    init() {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    var body: some Scene {
        Window("Preview", id: "preview") {
            ContentView()
                .frame(width: 800, height: 800)
        }
    }
}
