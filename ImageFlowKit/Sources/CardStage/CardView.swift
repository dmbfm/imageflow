import SwiftUI
import XViewKit

#if os(macOS)
import AppKit
#endif

final class CardView: XCommonView {
    var contentView: XView! {
        didSet {
            self.setupContentView()
        }
    }

    var radius: CGFloat = 10 {
        didSet {
            self.withLayer({ $0.cornerRadius = radius })
            self.contentView.withLayer({ $0.cornerRadius = radius })
        }
    }

    lazy var defaultContentView: XView = {
        let view = XCommonView()
        view.withLayer { layer in
            layer.backgroundColor = .teal
        }
        return view
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)

        self.canDrawSubviewsIntoLayer = true

        #if os(macOS)
        self.shadow = .init()
        #endif
        self.withLayer { layer in
            layer.cornerRadius = self.radius
            layer.cornerCurve = .continuous
            // layer.shadowColor = .init(gray: 0.5, alpha: 0.5)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 8
        }

        self.contentView = defaultContentView
        self.setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContentView() {
        self.wantsLayer = true
        self.contentView.removeFromSuperview()
        self.contentView.autoresizingMask = [.width, .height]
        // self.contentView.clipsToBounds = true
        self.contentView.wantsLayer = true
        self.contentView.shadow = .init()
        self.contentView.withLayer { layer in
            layer.cornerRadius = self.radius
            layer.cornerCurve = .continuous
        }
        self.addSubview(self.contentView)
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

#Preview {
    CardView.Preview()
}
