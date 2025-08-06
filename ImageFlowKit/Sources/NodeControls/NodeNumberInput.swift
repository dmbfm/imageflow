import Backend
import CommonUtils
import Design
import PlatformUtils
import Values
import SwiftUI

#if os(macOS)
import AppKit
import AppKitUtils
#endif

#if os(iOS)
import UIKit
#endif

public final class NodeNumberInput: PlatformView, NodeControl {
    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: PlatformColor = .blue

    public var valueDidChange: ((Value) -> ())?

    #if os(macOS)
    private lazy var textField: NSTextField = {
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = NSFont.systemFont(ofSize: 10)
        textField.drawsBackground = false
        textField.isBezeled = false
        textField.isBordered = false
        textField.focusRingType = .none
        textField.delegate = self
        textField.maximumNumberOfLines = 1
        textField.isSelectable = false
        textField.isEditable = false
        return textField
    }()
    #endif

    init(_ value: Value) {
        self.value = value
        
        super.init(frame: .zero)
        
        self.addSubview(self.textField)
        self.textField.constraintToFill(self)
        self.textField.stringValue = "\(self.value)"
    }

    public required init?(coder: NSCoder) {
        nil
    }
    
    public override var intrinsicContentSize: NSSize {
        .init(width: 200, height: 200)
    }

    func update() {}
}

#if os(macOS)
extension NodeNumberInput: NSTextFieldDelegate {
}
#endif

extension NodeNumberInput {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = NodeNumberInput(.float(0.5))
            return view
        }

        func updateView(_ view: ViewType, context: Context) {
        
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeNumberInput.Preview()
            .border(.gray)
    }
    .padding(100)
    .background(.white)
}
