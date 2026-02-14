#if os(macOS)

import AppKit
import Logging

@MainActor
class ColorPanelManager {

    private var kvo: NSKeyValueObservation? = nil
    private var onDiscreteChange: ((NSColor) -> ())?
    private var onContinuousChange: ((NSColor) -> ())?
    private var currentToken: UInt = 0

    typealias Token = UInt

    static let shared: ColorPanelManager = .init()

    private lazy var panel: NSColorPanel = {
        let panel = NSColorPanel.shared
        panel.setTarget(self)
        panel.setAction(#selector(Self.onPanelColorChanged(_:)))

        self.kvo = panel.observe(\.color, options: [.old, .new]) { [weak self] object, change in
            MainActor.assumeIsolated {
                self?.onObservation(of: object, change: change)
            }
        }

        return panel
    }()

    public func open(
        initialColor color: NSColor,
        showsAlpha: Bool = true,
        onDiscreteChange: @escaping (NSColor) -> (),
        onContinuousChange: @escaping (NSColor) -> (),
    ) -> Token {
        self.onDiscreteChange = nil
        self.onContinuousChange = nil

        self.panel.setTarget(nil)
        self.panel.setAction(nil)
        self.panel.color = color
        self.panel.showsAlpha = showsAlpha
        self.panel.setTarget(self)
        self.panel.setAction(#selector(Self.onPanelColorChanged(_:)))
        self.panel.orderFront(nil)

        self.onDiscreteChange = onDiscreteChange
        self.onContinuousChange = onContinuousChange

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

    private func onObservation(of panel: NSColorPanel, change: NSKeyValueObservedChange<NSColor>) {
        self.onContinuousChange?(panel.color)
    }

    @objc
    private func onPanelColorChanged(_ panel: NSColorPanel) {
        self.onDiscreteChange?(panel.color)
    }
}

#endif
