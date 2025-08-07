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
            }

            if self.text != self.textField.text {
                self.textField.text = self.text
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    public var textDidChange: ((String) -> ())?

    public var borderColor: UIColor {
        didSet {

        }
    }

    lazy var labelInsets: UIEdgeInsets = {
        .init(top: 4, left: 4, bottom: 4, right: 4)
    }()

    lazy var backgroundInsets: UIEdgeInsets = {
        .init(top: 2, left: 2, bottom: 2, right: 2)
    }()

    lazy var font: UIFont = {
        .preferredFont(forTextStyle: .caption1)
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.numberInputBackground.platformColor
        view.layer.cornerRadius = 4
        return view
    }()

    lazy var textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    }

    lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = self.text
        view.font = self.font
        view.numberOfLines = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var dummyLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        self.layer.cornerRadius = 6
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = .init(width: 0, height: 2)
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = 0

        self.addSubview(self.backgroundView)
        self.backgroundView.constraintToFill(self, edgeInsets: self.backgroundInsets)

        self.addSubview(self.textField)
        self.textField.constraintToFill(self, edgeInsets: self.labelInsets)
        self.textField.isHidden = true

        self.addSubview(self.label)
        self.label.constraintToFill(self, edgeInsets: self.labelInsets)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.onTapLabel))
        tapGesture.numberOfTapsRequired = 1
        self.label.addGestureRecognizer(tapGesture)
    }

    @objc
    func onTapLabel() {
        print("tap!!")
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
            self.layer.shadowOpacity = 0.6
            self.layer.borderWidth = 2
        }
    }
}

extension NodeTextFieldUIKit: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let text = self.textField.text {
            self.text = text
            self.textDidChange?(self.text)
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
            view.textDidChange = { value in
                self.text = value
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

#Preview {
    @Previewable @State var text: String = "Hello"
    VStack {
        NodeTextFieldUIKit.Preview($text)
        //            .border(.gray)
    }
    .padding(200)
    .background(.white)
}

#endif
