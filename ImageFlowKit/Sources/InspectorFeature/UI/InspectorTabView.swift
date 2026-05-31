#if os(macOS)

import XKit
import SwiftUI

class InspectorTabView: NSTabView {

    // MARK: - Properties

    var spacing: CGFloat = 24 {
        didSet {
            self.needsLayout = true
        }
    }

    var tabHeight: CGFloat {
        self.segmentedControlView.intrinsicContentSize.height + self.spacing
    }

    override var controlSize: NSControl.ControlSize {
        get {
            self.segmentedControlView.controlSize
        }
        set {
            self.segmentedControlView.controlSize = newValue
        }
    }

    // MARK: - Subviews

    lazy var segmentedControlView: NSSegmentedControl = {
        let view = NSSegmentedControl()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.trackingMode = .selectOne
        view.target = self
        view.action = #selector(Self.segmentedControlHandler)
        view.controlSize = .large
        return view
    }()

    // MARK: - Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.tabViewType = .noTabsNoBorder

        self.addSubview(self.segmentedControlView)
        self.updateSegmentedControl()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override var contentRect: NSRect {
        .init(x: 0, y: self.tabHeight, width: self.bounds.size.width, height: self.bounds.size.height - self.tabHeight)
    }

    override func layout() {
        super.layout()
        self.segmentedControlView.frame = .init(
            x: self.bounds.origin.x,
            y: self.bounds.origin.y,
            width: self.bounds.width,
            height: self.tabHeight
        )
    }

    // MARK: - Segmented Control

    @objc func segmentedControlHandler() {
        let index = self.segmentedControlView.selectedSegment
        self.selectTabViewItem(at: index)
    }

    func updateSegmentedControl() {
        let view = self.segmentedControlView
        view.segmentCount = self.tabViewItems.count
        for (idx, item) in self.tabViewItems.enumerated() {
            view.setLabel(item.label, forSegment: idx)
            view.setImage(item.image, forSegment: idx)
        }
        if let item = self.selectedTabViewItem, let index = self.tabViewItems.firstIndex(of: item) {
            view.selectedSegment = index
        }
    }

    // MARK: - Tab Selection

    override func selectTabViewItem(at index: Int) {
        super.selectTabViewItem(at: index)
        if self.segmentedControlView.selectedSegment != index {
            self.segmentedControlView.selectedSegment = index
        }
    }

    override func selectTabViewItem(_ tabViewItem: NSTabViewItem?) {
        super.selectTabViewItem(tabViewItem)
        if let item = tabViewItem, let index = self.tabViewItems.firstIndex(of: item),
            self.segmentedControlView.selectedSegment != index
        {
            self.segmentedControlView.selectedSegment = index
        }
    }

    // MARK: - Adding Tabs

    override func addTabViewItem(_ tabViewItem: NSTabViewItem) {
        super.addTabViewItem(tabViewItem)
        self.updateSegmentedControl()
    }
}

// MARK: - Previews

#Preview {
    let view = InspectorTabView()

    let redVC = NSHostingController(rootView: Color.red)
    let redItem = NSTabViewItem(viewController: redVC)
    redItem.label = "Red"
    redItem.image = NSImage(systemSymbolName: "person.fill", accessibilityDescription: nil)
    view.addTabViewItem(redItem)

    let blueVC = NSHostingController(rootView: Color.blue)
    let blueItem = NSTabViewItem(viewController: blueVC)
    blueItem.label = ""
    blueItem.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
    view.addTabViewItem(blueItem)

    return XSimpleViewRepresentable(view)
        .padding()
}

#endif
