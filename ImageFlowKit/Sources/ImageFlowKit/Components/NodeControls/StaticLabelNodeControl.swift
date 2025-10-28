import Helpers
import Values

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

public final class StaticLabelNodeControl: PlatformCommonView, NodeControl {
    public var onEvent: ((NodeControlEvent) -> ())?

    public var text: String

    public var tint: PlatformColor = .blue

    public var value: Value

    #if os(macOS)
    lazy var labelView: NSTextField = {
        let view = NSTextField(labelWithString: self.text)
        view.textColor = .secondaryLabelColor
        view.font = .systemFont(ofSize: 10)
        return view
    }()

    func platformInit() {
        self.wantsLayer = true
        self.layer?.backgroundColor = Colors.numberInputBackground.cgColor
        self.layer?.cornerRadius = 4
    }
    #endif

    #if os(iOS)
    lazy var labelView: UILabel = {
        let label = UILabel()
        label.text = self.text
        label.font = .preferredFont(forTextStyle: .caption2)
        label.text = self.text
        return label
    }()

    func platformInit() {
        self.backgroundColor = Colors.numberInputBackground.platformColor
        self.layer.cornerRadius = 4
    }
    #endif

    public init(_ value: Value, _ text: String) {
        self.value = value
        self.text = text

        super.init(frame: .zero)

        self.addSubview(self.labelView)

        self.platformInit()
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.labelView.intrinsicContentSize + .init(width: 4, height: 2)
    }

    public override func doLayout() {
        self.labelView.frame.origin = .zero
        self.labelView.frame.size = self.intrinsicContentSize
    }

}
