import SwiftUI
import Values
import XViewKit

public struct ColorPickerView: XViewRepresentable {

    @Binding var color: Color4
    @Environment(\.isEnabled) var isEnabled

    public init(color: Binding<Color4>) {
        self._color = color
    }

    public func makeView(context: Context) -> ColorPickerPlatformView {
        let view = ColorPickerPlatformView()
        view.color = self.color.xcolor  //XColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        view.showsAlpha = true
        view.onEvent = { event in
            switch event {
            case .didChange(let color):
                if let color = Color4(xcolor: color), self.color != color {
                    self.color = color
                }
            #if os(iOS)
            case .didCommit(old: _, new: _):
                break
            #endif
            }
        }
        view.isLocked = !self.isEnabled
        return view
    }

    public func updateView(_ view: ColorPickerPlatformView, context: Context) {
        if let color = Color4(xcolor: view.color), self.color != color {
            view.color = self.color.xcolor
        }

        view.isLocked = !self.isEnabled
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: ColorPickerPlatformView, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions()
        let height = view.intrinsicContentSize.height
        let width = proposal.width
        return .init(width: width, height: height)
    }
}

extension Color {
    init(xcolor: XColor) {
        #if os(macOS)
        self.init(nsColor: xcolor)
        #else
        self.init(uiColor: xcolor)
        #endif
    }
}

extension Color4 {
    var xcolor: XColor {
        .init(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }

    init?(xcolor: XColor) {
        #if os(macOS)
        self.init(nsColor: xcolor)
        #else
        self.init(uiColor: xcolor)
        #endif
    }
}
