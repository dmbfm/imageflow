//
//  NodeTextFieldUIKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

#if os(iOS)

import SwiftUI
import CommonUtils
import Logging
import Design
import ColorUtils

public final class NodeTextFieldUIKit: UIView {
    public var text: String {
        didSet {
            if self.text != self.label.text {
                self.label.text = self.text
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
            }

            if self.text != self.textField.text {
                self.textField.text = self.text
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
            }
        }
    }

    public enum Event {
        case textDidChange(String)
        case sizeDidChange
    }

    public var onEvent: ((Event) -> ())?

    public var borderColor: UIColor {
        didSet {

        }
    }

    lazy var labelInsets: UIEdgeInsets = {
        .init(top: 6, left: 8, bottom: 6, right: 8)
    }()

    lazy var backgroundInsets: UIEdgeInsets = {
        .init(top: 2, left: 2, bottom: 2, right: 2)
    }()

    lazy var font: UIFont = {
        .monospacedSystemFont(ofSize: 14, weight: .regular)
        //        .preferredFont(forTextStyle: .caption1)
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.numberInputBackground.platformColor
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()

    lazy var textField: UITextField = {
        let view = UITextField()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = self.font
        view.text = self.text
        view.delegate = self
        view.returnKeyType = .done
        view.addTarget(self, action: #selector(Self.onTextFieldChange), for: .editingChanged)
        view.keyboardType = .decimalPad
        return view
    }()

    @objc
    func onTextFieldChange() {
        self.label.text = self.textField.text
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    lazy var label: UILabel = {
        let view = UILabel()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = self.text
        view.font = self.font
        //        view.layer.borderWidth = 1
        view.numberOfLines = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var dummyLabel: UILabel = {
        let view = UILabel()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "X"
        view.font = self.font
        view.numberOfLines = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    init(_ text: String, borderColor: UIColor) {
        self.text = text
        self.borderColor = borderColor

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = .init(width: 0, height: 2)
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = 0

        self.addSubview(self.backgroundView)
        self.addSubview(self.textField)
        self.addSubview(self.label)

        self.textField.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.onTapLabel))
        tapGesture.numberOfTapsRequired = 1
        self.label.addGestureRecognizer(tapGesture)
    }

    @objc
    func onTapLabel() {
        self.state = .editing
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.label.intrinsicContentSize.max(self.dummyLabel.intrinsicContentSize) + self.labelInsets.size
    }

    enum State {
        case idle
        case editing
    }

    var state: State = .idle {
        didSet {
            self.update()
        }
    }

    func update() {
        switch self.state {
        case .idle:
            self.label.isHidden = false
            self.textField.isHidden = true
            self.layer.shadowOpacity = 0
            self.layer.borderWidth = 0
        case .editing:
            self.label.isHidden = true
            self.textField.isHidden = false
            self.textField.becomeFirstResponder()
            //            self.layer.shadowOpacity = 0.6
            self.layer.borderWidth = 2
        }
    }

    public override func layoutSubviews() {
        let size = self.intrinsicContentSize
        let rect = CGRect(origin: .zero, size: size)
        self.backgroundView.frame = rect.inset(by: self.backgroundInsets)  //self.ba //rect.i //.init(x: 2, y: 2, width: size.width - 4, height: size.height - 4)
        self.label.frame = rect.inset(by: self.labelInsets)
        self.textField.frame = rect.inset(by: self.labelInsets)
        //        self.label.frame = .init(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
        //        self.textField.frame = .init(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
    }
}

extension NodeTextFieldUIKit: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let text = self.textField.text {
            self.text = text
            self.onEvent?(.textDidChange(self.text))
        }
        self.state = .idle
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension NodeTextFieldUIKit {
    public struct Preview: UIViewRepresentable {

        @Binding var text: String

        public init(_ text: Binding<String>) {
            self._text = text
        }

        public func makeUIView(context: Context) -> NodeTextFieldUIKit {
            let view = NodeTextFieldUIKit(self.text, borderColor: .orange)
            view.onEvent = { event in
                switch event {
                case .textDidChange(let value): self.text = value
                case .sizeDidChange: break
                }
            }
            return view
        }

        public func updateUIView(_ uiView: NodeTextFieldUIKit, context: Context) {
            if uiView.text != self.text {
                uiView.text = self.text
            }
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? {
            uiView.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var text: String = "0.51"
    VStack {
        NodeTextFieldUIKit.Preview($text)
    }
    .padding(200)
    .background(.white)
}

#endif
