import AppKit

public extension NSColor {
    convenience init(light: NSColor, dark: NSColor?) {
        self.init(
            name: nil,
            dynamicProvider: { appearance in
                if appearance.isDarkMode {
                    dark ?? light
                } else {
                    light
                }
            }
        )
    }
}
