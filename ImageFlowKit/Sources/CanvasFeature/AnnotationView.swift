import CanvasView
import Helpers
import Logging
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class AnnotationView: PlatformView, CanvasNodeView {

    // MARK: - Common

    public var annotation: Annotation {
        didSet {
            if self.annotation != oldValue {
                self.update(oldValue)
            }
        }
    }

    public var id: UUID

    public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()

    var style: AnnotationStyle {
        self.annotation.type.style
    }

    init(_ id: UUID, _ annotation: Annotation) {
        self.id = id
        self.annotation = annotation
        super.init(frame: .zero)

        self.platformInit()
    }

    static func empty(width: CGFloat) -> AnnotationView {
        .init(.init(), .init(title: "", message: "", maxWidth: width, type: .regular))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update(_ oldValue: Annotation? = nil) {
        self.platformUpdate(oldValue)
    }

    // MARK: - iOS
    #if os(iOS)

    let padding: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
    let spacing: CGFloat = 4.0

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(self.titleLabel)
        stack.addArrangedSubview(self.messageLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = self.spacing
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = self.annotation.title
        label.textColor = self.style.titleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = self.annotation.message
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = self.style.messageColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 100
        return label
    }()

    lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        let glassEffect = UIGlassEffect()
        glassEffect.tintColor = self.style.backgroundColor
        view.effect = glassEffect
        view.cornerConfiguration = .corners(radius: .init(floatLiteral: self.style.cornerRadius))
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = self.style.cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    func platformInit() {
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = .init(width: 0, height: 0)

        self.addSubview(self.visualEffectView)
        self.addSubview(self.backgroundView)
        self.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.visualEffectView.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.visualEffectView.heightAnchor.constraint(equalTo: self.heightAnchor),

            self.backgroundView.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.backgroundView.heightAnchor.constraint(equalTo: self.heightAnchor),

            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.padding.top),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.padding.left),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.padding.bottom),
            self.messageLabel.widthAnchor.constraint(
                lessThanOrEqualToConstant: self.annotation.maxWidth - self.padding.left - self.padding.right
            ),
            //            self.stackView.widthAnchor.constraint(lessThanOrEqualToConstant: self.annotation.maxWidth - self.padding.left - self.padding.right),
        ])

        self.update()
    }

    func platformUpdate(_ oldValue: Annotation? = nil) {
        self.titleLabel.text = self.annotation.title
        self.messageLabel.text = self.annotation.message

        if self.annotation.type != oldValue?.type {
            self.titleLabel.textColor = self.style.titleColor

            self.messageLabel.textColor = self.style.messageColor

            if self.style.backgroundStyle != oldValue?.type.style.backgroundStyle {
                switch self.style.backgroundStyle {
                case .color:
                    if self.visualEffectView.superview != nil {
                        self.visualEffectView.removeFromSuperview()
                    }
                    if self.backgroundView.superview == nil {
                        self.insertSubview(self.backgroundView, at: 0)
                    }
                case .material:
                    if self.backgroundView.superview != nil {
                        self.backgroundView.removeFromSuperview()
                    }
                    if self.visualEffectView.superview == nil {
                        self.insertSubview(self.visualEffectView, at: 0)
                    }
                }
            }

            self.backgroundView.backgroundColor = self.style.backgroundColor
            self.backgroundView.layer.cornerRadius = self.style.cornerRadius
            (self.visualEffectView.effect as? UIGlassEffect)?.tintColor = self.style.backgroundColor
            self.visualEffectView.cornerConfiguration = .corners(
                radius: .init(floatLiteral: self.style.cornerRadius)
            )
        }

        self.invalidateIntrinsicContentSize()
        self.emitter.emit(.sizeChanged)
    }

    //    func updateBackground() {
    //        switch self.annotation.style.background {
    //        case .material:
    //            self.backgroundView.removeFromSuperview()
    //            if self.visualEffectView.superview != self {
    //                self.insertSubview(self.visualEffectView, at: 0)
    //            }
    ////            self.materialView.layer.cornerRadius = self.annotation.style.cornerRadius
    ////            self.materialView.clipsToBounds = true
    //        case .color(let color):
    //            self.visualEffectView.removeFromSuperview()
    //            if self.backgroundView.superview != self {
    //                self.insertSubview(self.backgroundView, at: 0)
    //            }
    //            self.backgroundView.backgroundColor = color
    //            self.backgroundView.clipsToBounds = true
    //            self.backgroundView.layer.cornerRadius = self.annotation.style.cornerRadius
    //            break
    //        }
    //    }

    override var intrinsicContentSize: CGSize {
        let titleSize = self.titleLabel.intrinsicContentSize
        let messageSize = self.messageLabel.sizeThatFits(.init(width: self.annotation.maxWidth, height: .infinity))
        return .init(
            width: max(messageSize.width.clamped(to: 0...self.annotation.maxWidth), titleSize.width) + self.padding.left
                + self.padding.right,
            height: titleSize.height + messageSize.height + self.spacing + self.padding.top + self.padding.bottom
        )
    }
    #endif

    // MARK: - macOS
    #if os(macOS)

    let padding: NSEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
    let spacing: CGFloat = 6.0

    lazy var titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: self.annotation.title)
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = self.style.titleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.maximumNumberOfLines = 1
        return label
    }()

    lazy var messageLabel: NSTextField = {
        let label = NSTextField(labelWithString: self.annotation.message)
        label.font = .systemFont(ofSize: 11)
        label.textColor = self.style.messageColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 100
        //        label.wantsLayer = true
        //        label.layer?.borderWidth = 4
        return label
    }()

    lazy var stackView: NSStackView = {
        let stack = NSStackView(views: [self.titleLabel, self.messageLabel])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = self.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.wantsLayer = true
        //        stack.layer?.borderWidth = 2
        //        stack.layer?.borderColor = .teal
        return stack
    }()

    lazy var backgroundView: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.cornerRadius = self.style.cornerRadius
        view.layer?.cornerCurve = .continuous
        return view
    }()

    lazy var visualEffectView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.material = .popover  //.hudWindow // .init(rawValue: 3)!
        view.blendingMode = .withinWindow
        view.layer?.cornerRadius = self.style.cornerRadius
        view.layer?.cornerCurve = .continuous
        return view
    }()

    func platformInit() {
        self.shadow = .init()
        self.wantsLayer = true
        self.layer?.shadowOpacity = 1.0
        self.layer?.shadowRadius = 8

        self.addSubview(self.visualEffectView)
        self.addSubview(self.backgroundView)
        self.addSubview(self.stackView)

        //        self.stackView.constraintToFill(self, edgeInsets: self.padding)
        self.backgroundView.constraintToFill(self)
        self.visualEffectView.constraintToFill(self)

        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.padding.left),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.padding.top),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.padding.bottom),

            self.messageLabel.widthAnchor.constraint(
                lessThanOrEqualToConstant: self.annotation.maxWidth - self.padding.left - self.padding.right
            ),
        ])

        self.update()
    }

    func platformUpdate(_ oldValue: Annotation? = nil) {
        self.titleLabel.stringValue = self.annotation.title
        self.messageLabel.stringValue = self.annotation.message

        if self.annotation.type != oldValue?.type {
            self.backgroundView.layer?.backgroundColor = self.style.backgroundColor?.cgColor
            self.backgroundView.layer?.cornerRadius = self.style.cornerRadius
            self.visualEffectView.layer?.cornerRadius = self.style.cornerRadius

            if self.style.backgroundStyle != oldValue?.type.style.backgroundStyle {
                switch self.style.backgroundStyle {
                case .color:
                    if self.visualEffectView.superview != nil {
                        self.visualEffectView.removeFromSuperview()
                    }
                    if self.backgroundView.superview == nil {
                        self.addSubview(self.backgroundView, positioned: .below, relativeTo: nil)
                    }
                case .material:
                    if self.backgroundView.superview != nil {
                        self.backgroundView.removeFromSuperview()
                    }

                    if self.visualEffectView.superview == nil {
                        self.addSubview(self.visualEffectView, positioned: .below, relativeTo: nil)
                    }
                }
            }
        }

        self.invalidateIntrinsicContentSize()
        self.emitter.emit(.sizeChanged)
    }

    var messageLabelSize: CGSize {
        let drawingRect =
            self.messageLabel.cell?.drawingRect(
                forBounds: .init(
                    origin: .zero,
                    size: .init(width: self.annotation.maxWidth, height: .infinity)
                )
            ) ?? .zero
        let size = self.messageLabel.cell!.cellSize(forBounds: drawingRect)
        return size
    }

    var titleLabelSize: CGSize {
        let drawingRect =
            self.titleLabel.cell?.drawingRect(
                forBounds: .init(origin: .zero, size: .init(width: 2000.0, height: .infinity))
            ) ?? .zero
        return self.titleLabel.cell!.cellSize(forBounds: drawingRect)
    }

    override var intrinsicContentSize: CGSize {
        let messageSize = self.messageLabelSize
        let titleSize = self.titleLabelSize
        let width: CGFloat =
            max(messageSize.width.clamped(to: 0...self.annotation.maxWidth), titleSize.width) + self.padding.left
            + self.padding.right
        let height: CGFloat =
            titleSize.height + messageSize.height + self.spacing + self.padding.top + self.padding.bottom
        return .init(width: width, height: height)
    }

    #endif

}

extension AnnotationView {
    struct Preview: PlatformViewRepresentable {
        let annotation: Annotation
        init(_ annotation: Annotation) {
            self.annotation = annotation
        }
        func makeView(context: Context) -> some PlatformView {
            AnnotationView(.init(), annotation)
        }

        func updateView(_ view: ViewType, context: Context) {
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview("short message") {
    VStack(alignment: .leading) {
        AnnotationView.Preview(.init(title: "Some title", message: "Some short not long message", maxWidth: 200))
    }
    //    .border(.red)
    .padding()
    .frame(minWidth: 500, minHeight: 500)
}

#Preview("long  message") {
    VStack {
        AnnotationView.Preview(
            .init(
                title: "Some title",
                message:
                    "Some short not long message actually very very long I was lying why I don't know I just felt like it I suppose no reason at all not a thought behind just a spur of the moment thing",
                maxWidth: 300,
            )
        )
        //        .border(.red)
    }
    .padding()
    .frame(minWidth: 500, minHeight: 500)
}

#Preview("long error message") {
    VStack {
        AnnotationView.Preview(
            .init(
                title: "Some title",
                message:
                    "Some short not long message actually very very long I was lying why I don't know I just felt like it I suppose no reason at all not a thought behind just a spur of the moment thing",
                maxWidth: 300,
                type: .error
            )
        )
    }
    .padding()
    .frame(minWidth: 500, minHeight: 500)
}
#Preview("long  title") {
    VStack {
        AnnotationView.Preview(
            .init(
                title: "Some very long title that explains too much for a unusnres trisentries ntriesnt riesnt risent",
                message: "very short message",
                maxWidth: 300,
            )
        )
        //        .border(.red)
    }
    .padding()
    .frame(minWidth: 500, minHeight: 500)
}
