import CanvasView
import Design
import Helpers
import SwiftUI

#if os(macOS)
import AppKit
#endif

final class AnnotationView: PlatformCommonView, CanvasNodeView {
    let id: UUID

    var level: Int

    let emitter: EventEmitter<CanvasNodeEvent<()>> = .init()

    func emitDragGesture(_ drag: CanvasNodeDragGesture) {
    }

    func emitClick() {
    }

    var annotation: Annotation = .init(title: "Some Titlez", message: "some message", maxWidth: 40) {
        didSet {
            if self.annotation != oldValue {
                self.update()
            }
        }
    }

    func update() {
        self.titleView.text = self.annotation.title
        self.messageView.text = self.annotation.message
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
        self.emitter.emit(.sizeChanged)
    }

    lazy var glassEffectView: NSGlassEffectView = {
        let view = NSGlassEffectView()
        view.style = .regular
        view.cornerRadius = 12
        return view
    }()

    lazy var titleView: NSTextField = {
        let view = NSTextField(labelWithString: "Some Title")
        view.font = .preferredFont(forTextStyle: .headline)
        return view
    }()

    lazy var messageView: NSTextField = {
        let view = NSTextField(
            labelWithString:
                "Here is a somewhat long message that we need to display to the user without any delay whatsoever."
        )
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .secondaryLabelColor
        view.maximumNumberOfLines = 100
        view.lineBreakStrategy = .standard
        view.lineBreakMode = .byWordWrapping
        return view
    }()

    init(id: UUID, frame: NSRect) {
        self.id = id
        self.level = 10
        super.init(frame: frame)

        self.addSubview(self.glassEffectView)
        self.addSubview(self.titleView)
        self.addSubview(self.messageView)

        self.clipsToBounds = false
        self.update()
    }

    static var empty: AnnotationView {
        let view = AnnotationView(id: .init(), frame: .zero)
        return view
    }

    required init?(coder: NSCoder) {
        nil
    }

    var maxWidth: CGFloat {
        self.annotation.maxWidth
    }

    var titleCanOverrideMaxWidth: Bool = true

    struct Style: Equatable {
        var insets: PlatformEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        var titleMessageSpacing: CGFloat = 4
    }

    var style: Style = .init() {
        didSet {
            self.setNeedsLayout()
            self.emitter.emit(.sizeChanged)
        }
    }

    var insets: PlatformEdgeInsets {
        self.style.insets
    }

    var titleMessageSpacing: CGFloat {
        self.style.titleMessageSpacing
    }

    override var intrinsicContentSize: NSSize {
        let titleSize = self.titleView.intrinsicContentSize + .init(width: 2, height: 0)

        let effectiveMaxWidth =
            if self.titleCanOverrideMaxWidth {
                max(titleSize.width, self.maxWidth)
            } else {
                self.maxWidth
            }

        let messageSize = self.messageView.sizeThatFits(.init(width: effectiveMaxWidth, height: .infinity))

        let width = messageSize.width.clamped(to: 0...effectiveMaxWidth) + self.insets.left + self.insets.right
        let width2 = titleSize.width + self.insets.left + self.insets.right
        let height =
            self.insets.top + titleSize.height + self.titleMessageSpacing + messageSize.height + self.insets.bottom

        return .init(width: max(width, width2), height: height)
    }

    override func doLayout() {
        self.glassEffectView.frame = self.bounds

        self.titleView.frame.origin.x = self.insets.left
        self.titleView.frame.origin.y = self.insets.top
        self.titleView.frame.size.width = self.bounds.width - self.insets.left - self.insets.right
        self.titleView.frame.size.height = self.titleView.intrinsicContentSize.height

        self.messageView.frame.origin.x = self.insets.left
        self.messageView.frame.origin.y = self.titleView.frame.maxY + self.titleMessageSpacing
        self.messageView.frame.size.width = self.bounds.width - self.insets.left - self.insets.right
        self.messageView.frame.size.height = self.bounds.height - self.messageView.frame.origin.y - self.insets.bottom
    }
}

#if os(macOS)
extension NSTextField {
    var estimatedSize: CGSize {
        NSAttributedString(
            string: self.text,
            attributes: [
                NSAttributedString.Key.font: self.font as Any
            ]
        ).size()
    }
}
extension NSEdgeInsets: @retroactive Equatable {
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        lhs.top == rhs.top && lhs.left == rhs.left && lhs.top == rhs.top && lhs.bottom == rhs.bottom
    }
}
#endif

extension AnnotationView {
    struct PreviewRepresentable: PlatformViewRepresentable {

        var isHidden: Bool = false

        func makeView(context: Context) -> AnnotationView {
            let view = AnnotationView(id: UUID(), frame: .init(x: 0, y: 0, width: 200, height: 200))
            view.annotation = .init(
                title: "Some Title",
                message:
                    "some long ass message that we really need the user to see so that he knows what te hell is going on you see it needs to be righ now.",
                maxWidth: 200
            )
            return view
        }

        func updateView(_ view: AnnotationView, context: Context) {
            if view.isHidden != self.isHidden {
                view.animator().isHidden = self.isHidden
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: AnnotationView, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var isHidden: Bool = false
    ZStack {
        Rectangle()
            .fill(
                Color.teal.opacity(0.5).gradient
            )
        VStack {
            AnnotationView.PreviewRepresentable(isHidden: isHidden)
            Button("Toggle") {
                isHidden.toggle()
            }
        }
        .padding()
    }
}
