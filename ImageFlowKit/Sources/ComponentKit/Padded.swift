import Helpers
import XKit

public final class Padded<V: XView>: XView, With {
    public let view: V

    public let insets: XEdgeInsets

    public init(_ view: V, insets: XEdgeInsets) {
        self.view = view
        self.insets = insets

        super.init(frame: .zero)

        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.constraintToFillSuperview(insets: insets)
    }

    public override var intrinsicContentSize: NSSize {
        return self.view.intrinsicContentSize
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
