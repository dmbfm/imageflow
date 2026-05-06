import Backend
import Helpers
import Logging
import SwiftUI
import Values
import XKit

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeRectInput: XViewEx, NodeControl {
    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: XColor = .systemBlue

    var isEditable: Bool {
        get {
            self.nodeVectorInput.isEditable
        }

        set {
            self.nodeVectorInput.isEditable = newValue
        }
    }

    var context: NodeControlContext = .init() {
        didSet {
            self.nodeVectorInput.context = self.innerContext
        }
    }

    var innerContext: NodeControlContext {
        .init(undo: UndoAdapter(control: self))
    }

    lazy var nodeVectorInput: NodeVectorInput = {
        let rect = self.value.rect
        let vec = Value.vector4(.init(x: rect.minX, y: rect.minY, z: rect.width, w: rect.height))
        let view = NodeVectorInput(vec)
        view.context = self.innerContext

        #if os(macOS)
        for (idx, controller) in view.textFields.enumerated() {
            controller.view.toolTip =
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
                let value: Value = .rect(.init(x: vec.x, y: vec.y, width: vec.z, height: vec.w))
                self?.setValue(newValue: value, registerUndo: true)
            // self?.setValue(vec)
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self?.emit(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
            case .statusBarMessage:
                break
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

    init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.nodeVectorInput.isEditable = isEditable

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

    override func layout() {
        super.layout()

        self.nodeVectorInput.frame.origin = .zero
        self.nodeVectorInput.frame.size = self.nodeVectorInput.intrinsicContentSize

        Layout.align(views: [self.nodeVectorInput], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}

@MainActor
private struct UndoAdapter: NodeControlUndoManager {
    weak var control: NodeRectInput?

    func register(_ oldValue: Values.Value, _ newValue: Values.Value) {
        let old = oldValue.vector4
        let new = newValue.vector4
        let oldValue = Value.rect(.init(x: old.x, y: old.y, width: old.z, height: old.w))
        let newValue = Value.rect(.init(x: new.x, y: new.y, width: new.z, height: new.w))
        self.control?.context.undo?.register(oldValue, newValue)
    }
}

extension NodeRectInput {
    struct Preview: XViewRepresentable {
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
