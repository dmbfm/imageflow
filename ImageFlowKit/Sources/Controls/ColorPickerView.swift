import Logging
import SwiftUI
import Values
import XViewKit

public struct ColorPickerView: XViewRepresentable {

    @Binding var color: Color4
    @Environment(\.isEnabled) var isEnabled
    var onCommit: ((_ newValue: Color4, _ oldValue: Color4?) -> ())?

    public init(color: Binding<Color4>, onCommit: ((_ newValue: Color4, _ oldValue: Color4?) -> ())? = nil) {
        self._color = color
        self.onCommit = onCommit
    }

    public func makeView(context: Context) -> ColorPickerPlatformView {
        let view = ColorPickerPlatformView()
        view.color = self.color.xcolor
        view.showsAlpha = true
        view.onEvent = { [weak coordinator = context.coordinator] event in
            coordinator?.onEvent(event)
        }
        view.isLocked = !self.isEnabled
        return view
    }

    public func updateView(_ view: ColorPickerPlatformView, context: Context) {
        if let color = Color4(xcolor: view.color), self.color != color {
            view.color = self.color.xcolor
        }

        view.isLocked = !self.isEnabled

        context.coordinator.onCommit = self.onCommit
        context.coordinator.color = self._color
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: ColorPickerPlatformView, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions()
        let height = view.intrinsicContentSize.height
        let width = proposal.width
        return .init(width: width, height: height)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator {

        var onCommit: ((_ newValue: Color4, _ oldValue: Color4?) -> ())?
        var color: Binding<Color4>?

        func onEvent(_ event: ColorPickerPlatformView.Event) {
            switch event {
            case .didChange(let change):
                if let color = Color4(xcolor: change.newValue), self.color?.wrappedValue != color || change.commit {
                    if change.commit, let onCommit = self.onCommit {
                        let old = change.oldValue.flatMap({ Color4(xcolor: $0) })
                        onCommit(color, old)
                    }

                    self.color?.wrappedValue = color
                }
            }
        }
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
