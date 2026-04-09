import Backend
import Controls
import Helpers
import Logging
import SwiftUI
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeColorInput: PlatformCommonView, NodeControl {

    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: PlatformColor = .systemBlue

    var context: NodeControlContext = .init()

    var platformColor: PlatformColor {
        switch self.value {
        case .color4(let color):
            return color.platformColor
        default:
            fatalError("Invalid type!")
        }
    }

    lazy var colorPicker: ColorPickerPlatformView = {
        let picker = ColorPickerPlatformView()
        picker.color = self.platformColor
        picker.commitedColor = self.platformColor
        picker.showsAlpha = self.value.type == .color4
        picker.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .didChange(let change):
                if let new = self.value(forPlatformColor: change.newValue) {
                    let old = change.oldValue.flatMap({ self.value(forPlatformColor: $0) })
                    self.setValue(newValue: new, oldValue: old, registerUndo: change.commit)
                }
            }
        }
        return picker
    }()

    var isEditable: Bool {
        get {
            !self.colorPicker.isLocked
        }

        set {
            self.colorPicker.isLocked = !newValue
        }
    }

    init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.colorPicker.isLocked = !isEditable

        self.addSubview(self.colorPicker)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func update() {
        switch self.value {
        case .color4(let c): self.colorPicker.color = c.platformColor
        default: break
        }
    }

    private func value(forPlatformColor color: PlatformColor) -> Value? {
        switch self.value.type {
        case .color4:
            if let color = Color4(platformColor: color) {
                return .color4(color)
            }
        default:
            return nil
        }

        return nil
    }

    override var intrinsicContentSize: CGSize {
        self.colorPicker.intrinsicContentSize
    }

    override func doLayout() {
        self.colorPicker.frame = .init(origin: .zero, size: self.colorPicker.intrinsicContentSize)

        Layout.align(views: [self.colorPicker], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}

extension Color4 {
    var platformColor: PlatformColor {
        #if os(macOS)
        self.nsColor
        #else
        self.uiColor
        #endif
    }

    init?(platformColor: PlatformColor) {
        #if os(macOS)
        self.init(nsColor: platformColor)
        #else
        self.init(uiColor: platformColor)
        #endif
    }
}

extension NodeColorInput {
    fileprivate struct Preview: PlatformViewRepresentable {

        let value: Value

        func makeView(context: Context) -> NodeColorInput {
            let view = NodeColorInput(self.value)
            return view
        }

        func updateView(_ view: NodeColorInput, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeColorInput, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeColorInput.Preview(value: .color4(.init(red: 1, green: 0, blue: 0, alpha: 0.5)))

        NodeView.Preview(node: .init(kind: .valueNode(.color4)))
    }
    .frame(minWidth: 500, minHeight: 500)
}
