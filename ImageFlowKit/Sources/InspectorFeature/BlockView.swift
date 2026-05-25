import XKit
import SwiftUI

class BlockView: XViewEx {
    
    var content: XView
    
    var cornerRadius: CGFloat = 8 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var contentInsets: XEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)  {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override var wantsUpdateLayer: Bool { true}
    
    var widthSizingMode: SizingMode = .fill
    var heightSizingMode: SizingMode = .contentIntrinsic
    
    enum SizingMode {
        case contentIntrinsic
        case fill
        case fixed(CGFloat)
    }
    
    init(_ content: XView) {
        self.content = content
        super.init(frame: .zero)
        
        self.addSubview(self.content)
        
    }
    
    override var isOpaque: Bool { false }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayer() {
        self.withLayer({ layer in
            layer.isOpaque = false
            layer.backgroundColor = XColor.system.secondaryFill.cgColor
            layer.cornerRadius = self.cornerRadius
            layer.cornerCurve = .continuous
        })
    }
    
    override var intrinsicContentSize: CGSize {
        let contentSize = self.content.intrinsicContentSize
        return CGSize(
            width: { () -> CGFloat in
                switch self.widthSizingMode {
                case .contentIntrinsic:
                    contentSize.width + self.contentInsets.left + self.contentInsets.right
                case .fill:
                    XView.noIntrinsicMetric
                case .fixed(let value):
                    value
                }
            }(),
            height: { () -> CGFloat in
                switch self.heightSizingMode {
                case .contentIntrinsic:
                    contentSize.height + self.contentInsets.top + self.contentInsets.bottom
                case .fill:
                    XView.noIntrinsicMetric
                case .fixed(let value):
                    value
                }
            }()
        )
    }
    
    override func layout() {
        self.content.frame.origin.x = self.bounds.origin.x + self.contentInsets.left
        self.content.frame.origin.y = self.bounds.origin.y + self.contentInsets.top
        self.content.frame.size.width = self.bounds.width - (self.contentInsets.left + self.contentInsets.right)
        self.content.frame.size.height = self.bounds.height - (self.contentInsets.top + self.contentInsets.bottom)
    }
}

fileprivate struct PreviewRepresentable: XViewRepresentable {
    func makeView(context: Context) -> some NSView {
        BlockView(NSTextField(labelWithString: "Hello!!"))
    }
    
    func updateView(_ view: ViewType, context: Context) {
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
        return .init(width: proposal.replacingUnspecifiedDimensions().width, height: view.intrinsicContentSize.height)
//        view.intrinsicCon
    }
}

#Preview {
    VStack {
        PreviewRepresentable()
            .padding(100)
    }
}
