//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

import AppKit
import SwiftUI
import CommonUtils
import Logging
import Design
import ColorUtils

public final class NodeTextFieldAppKit: NSView {
    public var text: String {
        didSet {
            
        }
    }
    
    public var borderColor: DynamicColor {
        didSet {
            
        }
    }
    
    lazy var label: NSTextField = {
        let label = NSTextField(labelWithString: self.text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    lazy var textField: NSTextField = {
        let view = NSTextField()
        view.font = .systemFont(ofSize: 10)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.stringValue = self.text
        view.isBezeled = false
        view.drawsBackground = false
        view.isBordered = false
        view.focusRingType = .none
        view.maximumNumberOfLines = 1
        view.delegate = self
        return view
    }()
    
    struct Style {
        var labelInsets: NSEdgeInsets = .init(top: 2, left: 4, bottom: 2, right: 4)
    }
    
    var style = Style()
    
    init(_ text: String, borderColor: DynamicColor) {
        self.text = text
        self.borderColor = borderColor
        super.init(frame: .zero)
        self.addSubview(self.label)
        
        self.wantsLayer = true
        
        self.label.constraintToFill(self, edgeInsets: style.labelInsets)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = Colors.numberInputBackground.cgColor
        self.layer?.cornerRadius = 5.0
    }
    
    public required init?(coder: NSCoder) {
        nil
    }
    
    
    public override var intrinsicContentSize: NSSize {
        self.label.intrinsicContentSize + style.labelInsets.size
    }
    
    public override func mouseDown(with event: NSEvent) {
        self.beginEditing()
    }
    
    enum State {
        case idle
        case editing
    }
    
    var state = State.idle
    
    func beginEditing() {
        if self.state == .idle {
            self.label.removeFromSuperview()
            self.addSubview(self.textField)
            self.textField.constraintToFill(self, edgeInsets: self.style.labelInsets)
            self.window?.makeFirstResponder(self.textField)
            self.state = .editing
            self.shadow(.init(radius: 4))
            self.border(.init(color: self.borderColor.platformColor, width: 2))
        }
    }
    
    func endEditing() {
        if self.state == .editing {
            self.textField.removeFromSuperview()
            self.addSubview(self.label)
            self.label.constraintToFill(self, edgeInsets: self.style.labelInsets)
            self.shadow(nil)
            self.border(nil)
            self.state = .idle
        }
    }
}

extension NodeTextFieldAppKit: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        self.label.stringValue = self.textField.stringValue
        self.invalidateIntrinsicContentSize()
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        self.endEditing()
    }
}

extension NSEdgeInsets {
    var size: CGSize {
        .init(width: self.left + self.right, height: self.top + self.bottom)
    }
}

extension NodeTextFieldAppKit {
    
    
    fileprivate struct Preview: NSViewRepresentable {
        func makeNSView(context: Context) -> some NSView {
            NodeTextFieldAppKit("Hello", borderColor: .blue)
        }
        
        func updateNSView(_ nsView: NSViewType, context: Context) {
        }
        
        func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSViewType, context: Context) -> CGSize? {
            nsView.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeTextFieldAppKit.Preview()
//            .border(.gray)
    }
    .padding(100)
    .background(.white)
}


