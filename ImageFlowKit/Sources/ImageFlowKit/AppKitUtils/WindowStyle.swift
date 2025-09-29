#if canImport(AppKit)

import AppKit

@MainActor
public struct WindowStyle: Hashable, With {
    public var toolbarDisplayMode: NSToolbar.DisplayMode
    public var toolbarStyle: NSWindow.ToolbarStyle
    public var titlebarSeparatorStyle: NSTitlebarSeparatorStyle
    public var titlebarAppearsTransparent: Bool
    public var titleVisibility: NSWindow.TitleVisibility
    public var fullSizeContentView: Bool

    init(
        toolbarDisplayMode: NSToolbar.DisplayMode,
        toolbarStyle: NSWindow.ToolbarStyle,
        titlebarSeparatorStyle: NSTitlebarSeparatorStyle,
        titlebarAppearsTransparent: Bool,
        titleVisibility: NSWindow.TitleVisibility,
        fullSizeContentView: Bool = false
    ) {
        self.toolbarDisplayMode = toolbarDisplayMode
        self.toolbarStyle = toolbarStyle
        self.titlebarSeparatorStyle = titlebarSeparatorStyle
        self.titlebarAppearsTransparent = titlebarAppearsTransparent
        self.titleVisibility = titleVisibility
        self.fullSizeContentView = fullSizeContentView
    }

    public static let compact: Self = .init(
        toolbarDisplayMode: .iconOnly,
        toolbarStyle: .unifiedCompact,
        titlebarSeparatorStyle: .line,
        titlebarAppearsTransparent: false,
        titleVisibility: .visible
    )

    public static let large: Self = .init(
        toolbarDisplayMode: .iconOnly,
        toolbarStyle: .unified,
        titlebarSeparatorStyle: .line,
        titlebarAppearsTransparent: false,
        titleVisibility: .visible
    )

    public static let largeTransparent: Self = Self.large.with(\.titlebarAppearsTransparent, true)

    public func apply(_ window: NSWindow) {
        window.toolbarStyle = self.toolbarStyle
        window.titlebarAppearsTransparent = self.titlebarAppearsTransparent
        window.titlebarSeparatorStyle = self.titlebarSeparatorStyle
        window.titleVisibility = self.titleVisibility

        if self.fullSizeContentView {
            window.styleMask.insert(.fullSizeContentView)
        } else {
            window.styleMask.remove(.fullSizeContentView)
        }

        if let toolbar = window.toolbar {
            toolbar.displayMode = self.toolbarDisplayMode
        }
    }
}

#endif
