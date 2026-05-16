#if os(macOS)

import AppKit
import XKit
import SharedModels

class NodeSearchPopoverListItemView: XViewEx {

    var item: NodePaletteItem

    lazy var imageView: NSImageView = {
        let image = NSImage(systemSymbolName: self.item.icon, accessibilityDescription: nil) ?? .init()
        let view = NSImageView(image: image)
        view.symbolConfiguration = .init(pointSize: 20, weight: .regular)
        view.layerContentsPlacement = .left
        view.wantsLayer = true
        view.contentTintColor = .labelColor
        return view
    }()

    lazy var labelView: NSTextField = {
        let view = NSTextField(labelWithString: self.item.displayName)
        view.font = .preferredFont(forTextStyle: .caption1)
        view.textColor = .labelColor
        return view
    }()

    lazy var categoryLabelView: NSTextField = {
        let view = NSTextField(labelWithString: self.item.categoryName.rawValue + " 􀆓")
        view.font = .preferredFont(forTextStyle: .caption1)
        view.textColor = .tertiaryLabelColor
        return view
    }()

    init(item: NodePaletteItem) {
        self.item = item
        super.init(frame: .zero)

        self.addSubview(self.categoryLabelView)
        self.addSubview(self.imageView)
        self.addSubview(self.labelView)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        let imageSize = self.imageView.intrinsicContentSize
        let labelSize = self.labelView.intrinsicContentSize
        return .init(
            width: imageSize.width + labelSize.width,
            height: max(imageSize.height, labelSize.height)
        )
    }

    override func layout() {
        super.layout()
        var x = self.bounds.minX

        self.categoryLabelView.frame.origin.x = x
        self.categoryLabelView.frame.size.height = self.categoryLabelView.intrinsicContentSize.height
        self.categoryLabelView.frame.size.width = self.categoryLabelView.intrinsicContentSize.width + 4
        self.categoryLabelView.frame.setCenterY(self.bounds.center.y)

        x += self.categoryLabelView.frame.maxX

        self.imageView.frame.origin.x = x
        self.imageView.frame.size = .init(width: 20, height: self.imageView.intrinsicContentSize.height)
        self.imageView.frame.setCenterY(self.bounds.center.y)

        x = self.imageView.frame.maxX

        self.labelView.frame.origin.y = self.bounds.origin.y
        self.labelView.frame.origin.x = x
        self.labelView.frame.size.height = self.labelView.intrinsicContentSize.height
        self.labelView.frame.size.width = self.bounds.width - x

        self.labelView.frame.setCenterY(self.bounds.center.y)
    }
}

#endif
