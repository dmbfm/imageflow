import SwiftUI
import XKit

#if os(macOS)
import AppKit
#endif

final class CardView: XViewEx {

    var contentView: XView! {
        willSet {
            if !self.lock {
                self.contentView.removeFromSuperview()
            }
        }
        didSet {
            if !self.lock {
                self.setupContentView()
            }
        }
    }

    var radius: CGFloat = 10 {
        didSet {
            self.contentView.withLayer({ $0.cornerRadius = radius })
        }
    }

    var lock: Bool = false

    lazy var defaultContentView: XView = {
        let view = DefaultContentView()
        view.autoresizingMask = [.width, .height]
        view.frame = self.bounds
        return view
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)

        self.autoresizesSubviews = true
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        //        self.clipsToBounds = true

        #if os(macOS)
        self.shadow = .init()
        #endif
        self.withLayer { layer in
            layer.cornerRadius = self.radius
            layer.cornerCurve = .continuous
            layer.masksToBounds = true
            // layer.shadowColor = .init(gray: 0.5, alpha: 0.5)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 8
            //            self.shadow  = .init()
        }

        self.contentView = defaultContentView

        self.setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContentView() {

        //        self.wantsLayer = true
        self.contentView.wantsLayer = true
        self.contentView.autoresizingMask = [.width, .height]
        self.contentView.frame = self.bounds
        // self.contentView.clipsToBounds = true
        //        self.contentView.shadow = .init()
        //        self.contentView.clipsToBounds = true
        //        self.contentView.canDrawSubviewsIntoLayer = true
        self.contentView.withLayer { layer in
            layer.masksToBounds = true
            layer.cornerRadius = self.radius
            layer.cornerCurve = .continuous
        }
        self.addSubview(self.contentView)
    }
}

extension CGRect {
    mutating func setCenter(_ point: CGPoint) {
        self.origin.x = point.x - self.width * 0.5
        self.origin.y = point.y - self.width * 0.5
    }
}

extension CardView {
    struct Preview: View {
        var body: some View {
            VStack {
                PreviewRepresentable(content: nil as EmptyView?)
                    .frame(width: 250, height: 250)
                    .padding()

                PreviewRepresentable(content: self.content)
                    .frame(width: 250, height: 250)
                    .padding()
            }
        }

        var content: some View {
            ZStack {
                Color.orange
                Text("Card View!")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }

    struct PreviewRepresentable<Content: View>: XViewRepresentable {

        var content: Content?

        func makeView(context: Context) -> CardView {
            let view = CardView()
            if let content = self.content {
                view.contentView = NSHostingView(rootView: content)
            }
            return view
        }

        func updateView(_ view: CardView, context: Context) {

        }
    }
}

class DefaultContentView: XView {
    lazy var label: NSTextField = {
        let view = NSTextField(labelWithString: "Card View")
        return view
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.systemIndigo.cgColor
        self.addSubview(self.label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        self.label.frame = self.bounds
    }
}

#Preview {
    CardView.Preview()
}
