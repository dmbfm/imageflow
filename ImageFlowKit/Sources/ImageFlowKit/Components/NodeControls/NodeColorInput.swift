import Backend
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

    var platformColor: PlatformColor {
        switch self.value {
        case .color3(let color):
            return color.platformColor
        case .color4(let color):
            return color.platformColor
        default:
            fatalError("Invalid type!")
        }
    }

    lazy var colorPicker: NodeColorPicker = {
        let picker = NodeColorPicker()
        picker.color = self.platformColor
        picker.showsAlpha = self.value.type == .color4
        picker.colorDidChange = { [weak self] color in
            self?.setValue(color)
        }
        return picker
    }()

    init(_ value: Value) {
        self.value = value

        super.init(frame: .zero)

        self.addSubview(self.colorPicker)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func update() {}

    private func setValue(_ color: PlatformColor) {
        switch self.value.type {
        case .color3:
            if let color = Color3(platformColor: color) {
                self.value = .color3(color)
            }
        case .color4:
            if let color = Color4(platformColor: color) {
                self.value = .color4(color)
            }
        default:
            fatalError("Invalid type")
        }
        self.emit(.valueDidChange(self.value))
    }

    override var intrinsicContentSize: CGSize {
        self.colorPicker.intrinsicContentSize
    }

    override func doLayout() {
        self.colorPicker.frame = .init(origin: .zero, size: self.colorPicker.intrinsicContentSize)

        Layout.align(views: [self.colorPicker], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}

extension Color3 {
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
        NodeColorInput.Preview(value: .color3(.init(red: 1, green: 0, blue: 0)))
        NodeColorInput.Preview(value: .color4(.init(red: 1, green: 0, blue: 0, alpha: 0.5)))

        NodeView.Preview(node: .init(kind: .valueNode(.color4)))
    }
    .frame(minWidth: 500, minHeight: 500)
}
