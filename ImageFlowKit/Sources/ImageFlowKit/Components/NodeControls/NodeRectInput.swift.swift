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

final class NodeRectInput: PlatformCommonView, NodeControl {
    public var onEvent: ((NodeControlEvent) -> ())?

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: PlatformColor = .systemBlue

    lazy var nodeVectorInput: NodeVectorInput = {
        let rect = self.value.rect
        let vec = Value.vector4(.init(x: rect.minX, y: rect.minY, z: rect.width, w: rect.height))
        let view = NodeVectorInput(vec)

        #if os(macOS)
        for (idx, view) in view.textFields.enumerated() {
            view.toolTip =
                switch idx {
                case 0: "origin x coordinate"
                case 1: "origin y coordinate"
                case 2: "width"
                case 3: "height"
                default: ""
                }
        }
        #endif

        view.onEvent = { [weak self] event in
            switch event {
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
                self?.setNeedsLayout()
            case .valueDidChange(let value):
                let vec = value.vector4
                self?.setValue(vec)
            }
        }

        return view
    }()

    func setValue(_ vec: Vector4) {
        let value: Value = .rect(.init(x: vec.x, y: vec.y, width: vec.z, height: vec.w))

        if self.value != value {
            self.value = value
            self.emit(.valueDidChange(self.value))
        }
    }

    init(_ value: Value) {
        self.value = value

        super.init(frame: .zero)

        self.addSubview(self.nodeVectorInput)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func update() {
        let rect = self.value.rect
        let vec = Value.vector4(.init(x: rect.minX, y: rect.minY, z: rect.width, w: rect.height))

        if self.nodeVectorInput.value != vec {
            self.nodeVectorInput.value = vec
        }
    }

    override var intrinsicContentSize: CGSize {
        self.nodeVectorInput.intrinsicContentSize
    }

    override func doLayout() {
        self.nodeVectorInput.frame.origin = .zero
        self.nodeVectorInput.frame.size = self.nodeVectorInput.intrinsicContentSize

        Layout.align(views: [self.nodeVectorInput], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}

extension NodeRectInput {
    struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeRectInput {
            let view = NodeRectInput(.rect(.init()))
            view.onEvent = { event in
                log("event: \(event)")
            }
            return view
        }

        func updateView(_ view: NodeRectInput, context: Context) {
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeRectInput, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeRectInput.Preview()
    }
    .padding(80)
}
