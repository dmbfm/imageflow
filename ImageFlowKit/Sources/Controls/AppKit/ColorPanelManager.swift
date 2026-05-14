#if os(macOS)

import AppKit

@MainActor
class ColorPanelManager {
    private var onChange: ((NSColor) -> ())?
    private var currentToken: UInt = 0

    typealias Token = UInt

    static let shared: ColorPanelManager = .init()

    private lazy var panel: NSColorPanel = {
        let panel = NSColorPanel.shared
        panel.setTarget(self)
        panel.setAction(#selector(Self.onPanelColorChanged(_:)))
        return panel
    }()

    public func open(
        initialColor color: NSColor,
        showsAlpha: Bool = true,
        onChange: @escaping (NSColor) -> (),
    ) -> Token {
        self.panel.setTarget(nil)
        self.panel.setAction(nil)
        self.panel.color = color
        self.panel.showsAlpha = showsAlpha
        self.panel.setTarget(self)
        self.panel.setAction(#selector(Self.onPanelColorChanged(_:)))
        self.panel.orderFront(nil)
        self.panel.isContinuous = true

        self.onChange = onChange

        self.nextToken()
        return self.currentToken
    }

    private func nextToken() {
        self.currentToken = self.currentToken &+ 1
    }

    func setColor(color: NSColor, token: Token) {
        if token == self.currentToken {
            self.panel.color = color
        }
    }

    @objc
    private func onPanelColorChanged(_ panel: NSColorPanel) {
        self.onChange?(panel.color)
    }
}

#endif
