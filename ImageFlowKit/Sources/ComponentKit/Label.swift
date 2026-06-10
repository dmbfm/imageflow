import XKit
import Helpers
import Combine

public final class Label: XLabel, Rx, WithRef {
    public var cancellables: Set<AnyCancellable> = []

    public init(_ label: String, font: XFont? = nil, alignment: NSTextAlignment? = nil) {
        super.init(frame: .zero)
        self.text = label

        self.isEditable = false
        self.isBordered = false
        self.isSelectable = false
        self.font = font ?? .preferredFont(forTextStyle: .body)
        self.textColor = .labelColor
        self.usesSingleLineMode = true
        self.lineBreakMode = .byTruncatingTail
        self.drawsBackground = false
        self.alignment = alignment ?? .left
    }

    public func withTextColor(_ color: XColor) -> Self {
        self.textColor = color
        return self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    Label("Hello!")
}
