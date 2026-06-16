import XKit

public class Spacer: XView {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.setContentHuggingPriority(.defaultLow - 100, for: .horizontal)
        self.setContentHuggingPriority(.defaultLow - 100, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
