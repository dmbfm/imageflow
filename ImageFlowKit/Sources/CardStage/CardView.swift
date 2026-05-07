import SwiftUI
import XKit

#if os(macOS)
import AppKit
#endif

private final class ContentConainer: XViewEx {

    var content: XView {
        willSet {
            self.content.removeFromSuperview()
        }
        didSet {
            self.addSubview(self.content)
            self.setNeedsLayout()
        }
    }

    init(_ content: XView) {
        self.content = content

        super.init(frame: .zero)

        self.clipsToBounds = true
        self.withLayer { layer in
            layer.masksToBounds = true
        }

        self.addSubview(content)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        self.content.frame = self.bounds
    }
}

final class CardView: XViewEx {

    var contentView: XView! {
        didSet {
            self.contentContainer.content = self.contentView
            self.setNeedsLayout()
            self.update()
        }
    }

    var radius: CGFloat = 10 {
        didSet {
            self.update()
        }
    }

    var shadowStyle: XViewEx.Shadow? = nil {
        didSet {
            self.updateShadow(self.shadowStyle)
        }
    }

    private lazy var contentContainer: ContentConainer = {
        let view = ContentConainer(self.contentView)
        view.clipsToBounds = true
        return view
    }()

    lazy var defaultContentView: XView = {
        let view = DefaultContentView()
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.contentView = self.defaultContentView
        self.addSubview(self.contentContainer)

        #if os(macOS)
        self.wantsLayer = true
        self.canDrawSubviewsIntoLayer = true
        #endif

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {

        #if os(macOS)
        if self.shadow == nil {
            self.shadow = .init()
        }
        #endif

        self.withLayer { layer in
            // layer.backgroundColor = .clear
            layer.cornerRadius = self.radius
            layer.cornerCurve = .continuous
            layer.shadowColor = .init(gray: 0, alpha: 0.4)
            layer.shadowRadius = 4
            layer.shadowOpacity = 1.0
            layer.shadowOffset = .zero
        }

        self.contentContainer.withLayer { layer in
            layer.cornerRadius = self.radius
            layer.cornerCurve = .continuous
            layer.masksToBounds = true
        }
    }

    override func layout() {
        super.layout()

        self.contentContainer.frame = self.bounds
    }

    // var contentView: XView! {
    //     willSet {
    //         if !self.lock {
    //             self.contentView.removeFromSuperview()
    //         }
    //     }
    //     didSet {
    //         if !self.lock {
    //             self.setupContentView()
    //         }
    //     }
    // }

    // var radius: CGFloat = 10 {
    //     didSet {
    //         self.contentView.withLayer({ $0.cornerRadius = radius })
    //     }
    // }

    // var lock: Bool = false

    // lazy var defaultContentView: XView = {
    //     let view = DefaultContentView()
    //     view.autoresizingMask = [.width, .height]
    //     view.frame = self.bounds
    //     return view
    // }()

    // override init(frame frameRect: NSRect) {

    //     super.init(frame: frameRect)

    //     self.contentView = defaultContentView
    //     self.setupContentView()

    //     //        self.contentView = defaultContentView
    //     //        self.setupContentView()
    // }

    // override func layout() {
    //     super.layout()
    //     self.contentView.frame = self.bounds
    // }

    // required init?(coder: NSCoder) {
    //     fatalError("init(coder:) has not been implemented")
    // }

    // func setupContentView() {

    //     self.addSubview(self.contentView)

    //     // //        self.wantsLayer = true
    //     // self.contentView.wantsLayer = true
    //     // self.contentView.autoresizingMask = [.width, .height]
    //     // self.contentView.frame = self.bounds
    //     // // self.contentView.clipsToBounds = true
    //     // //        self.contentView.shadow = .init()
    //     // //        self.contentView.clipsToBounds = true
    //     // //        self.contentView.canDrawSubviewsIntoLayer = true
    //     // self.contentView.withLayer { layer in
    //     //     layer.masksToBounds = true
    //     //     layer.cornerRadius = self.radius
    //     //     layer.cornerCurve = .continuous
    //     // }
    // }
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
                    .padding()
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
