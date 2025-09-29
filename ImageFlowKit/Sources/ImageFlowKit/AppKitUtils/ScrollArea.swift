#if canImport(AppKit)

import AppKit

public class ScrollArea: NSView {

    // MARK: - Public properties

    public var documentView: NSView = NSView()

    public lazy var clipView: NSView = {
        let view = ClipView()
        return view
    }()
}

extension ScrollArea {
    public class ClipView: NSView {

    }
}

#endif
