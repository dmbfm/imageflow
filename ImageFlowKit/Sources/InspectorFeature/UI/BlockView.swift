import SwiftUI
import XKit

class BlockView: XViewEx {

    var content: XView {
        didSet {
            self.content.removeFromSuperview()
            self.setupView()
        }
    }

    var insets: XEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            self.content.removeFromSuperview()
            self.setupView()
        }
    }

    var radius: CGFloat = 10 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var backgroundColor: XColor = .system.quaternaryFill {
        didSet {
            self.setNeedsDisplay()
        }
    }

    init(_ content: XView) {
        self.content = content

        super.init(frame: .zero)

        self.wantsLayer = true

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.content.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.content)
        NSLayoutConstraint.activateConstraint(self.content, toFill: self, insets: self.insets)
    }

    override func draw(_ dirtyRect: NSRect) {
        self.layer?.cornerRadius = self.radius
        self.layer?.backgroundColor = self.backgroundColor.cgColor
    }
}

#Preview {
    VStack {
        XSimpleViewRepresentable(BlockView(XTextField(labelWithString: "Hello Block!")))
            .padding()
    }
}
