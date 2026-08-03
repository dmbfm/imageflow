import Helpers
import XKit
import Combine

public final class FontPicker: XView, WithRef, NSFontChanging, NSWindowDelegate {

    @PublishedEx public var fontName: String = NSFont.userFont(ofSize: NSFont.systemFontSize)!.fontName {
        didSet {
            if self.fontName != oldValue {
                self.update()
            }
        }
    }

    public var onChange: ((String) -> ())?

    public var isEnabled: Bool {
        get { self.button.isEnabled }
        set { self.button.isEnabled = newValue }
    }

    var font: NSFont {
        NSFont.init(name: self.fontName, size: NSFont.systemFontSize) ?? .userFont(ofSize: NSFont.systemFontSize)!
    }

    lazy var button: Button = {
        Button("Choose a font...") { [weak self] in
            self?.openFontPanel()
        }
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
        .withContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        .withContentHuggingPriority(.defaultLow - 10, for: .horizontal)
    }()

    public override var intrinsicContentSize: NSSize {
        self.button.intrinsicContentSize
    }

    public init(_ fontName: String? = nil) {
        if let fontName {
            self.fontName = fontName
        }
        super.init(frame: .zero)

        // NSFont(descriptor: NSFontDescriptor, size: CGFloat)

        self.addSubview(self.button)
        self.button.constraintToFillSuperview()
        // NSLayoutConstraint.activate([
        //     self.button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        //     self.button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        //     self.button.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 1.0),
        // ])

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if NSFontManager.shared.target === self {
            NSFontManager.shared.target = nil
        }
    }

    func openFontPanel() {
        let manager = NSFontManager.shared
        manager.target = self
        manager.setSelectedFont(self.font, isMultiple: false)
        if let panel = manager.fontPanel(true) {
            panel.delegate = self
            panel.setPanelFont(self.font, isMultiple: false)
            panel.makeKeyAndOrderFront(nil)
        }
    }

    @objc public func changeFont(_ sender: NSFontManager?) {
        guard let fm = sender else { return }
        let newFontName = fm.convert(fm.selectedFont ?? self.font).fontName
        if newFontName != self.fontName {
            self.fontName = newFontName
            self.onChange?(self.fontName)
        }
    }

    public func validModesForFontPanel(_ fontPanel: NSFontPanel) -> NSFontPanel.ModeMask {
        return [.face]
    }

    public func update() {
        print("font name: \(self.font.fontName)")
        self.button.title = "\(self.font.displayName ?? self.fontName)"
        NSFontManager.shared.setSelectedFont(self.font, isMultiple: false)
    }
}

#Preview {
    FontPicker()
}
