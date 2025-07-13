import AppKit
import SwiftUI

public class GrowableTextField: NSTextField {

    public weak var growableTextFieldDelegate: (any Delegate)?

    private var currentCalcutatedSize: NSSize?

    public var rightMargin: CGFloat = 15 {
        didSet {
            self.currentCalcutatedSize = nil
            self.recalculateTextSize()
        }
    }

    override public var stringValue: String {
        didSet {
            self.recalculateTextSize()
        }
    }

    override public func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        self.recalculateTextSize()
    }

    private func recalculateTextSize() {
        let str = self.stringValue
        let cell = NSCell(textCell: str)
        cell.font = self.font
        let newWidth = cell.cellSize.width

        if newWidth != self.currentCalcutatedSize?.width {
            var size = super.intrinsicContentSize
            size.width = newWidth + self.rightMargin
            self.currentCalcutatedSize = size
            self.invalidateIntrinsicContentSize()
            self.growableTextFieldDelegate?.growableTextField(sizeDidChangeTo: size)
        }
    }

    override public var intrinsicContentSize: NSSize {
        if self.currentCalcutatedSize == nil {
            self.recalculateTextSize()
        }

        return self.currentCalcutatedSize!
    }
}

extension GrowableTextField {
    @MainActor
    public protocol Delegate: AnyObject {
        func growableTextField(sizeDidChangeTo newSize: NSSize)
    }
}

extension GrowableTextField {
    fileprivate struct Preview: NSViewRepresentable {
        func makeNSView(context: Context) -> some NSView {
            GrowableTextField()
        }

        func updateNSView(_ nsView: NSViewType, context: Context) {

        }
    }
}

#Preview {
    GrowableTextField.Preview()
        .fixedSize()
        .padding(80)
}
