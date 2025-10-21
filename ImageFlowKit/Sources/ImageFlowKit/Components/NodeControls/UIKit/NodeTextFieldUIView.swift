//
//  NodeTextFieldUIKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

#if os(iOS)

import Helpers
import SwiftUI
import Logging

final class NodeTextFieldUIView: UIView, NodeTextFieldProtocol {
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

    public var onEvent: ((NodeTextFieldEvent) -> ())?

    private var style: NodeTextFieldStyle

    lazy var font: UIFont = {
        switch self.style.fontDesign {
        case .regular:
            .systemFont(ofSize: self.style.fontSize)
        case .monospaced:
            .monospacedSystemFont(ofSize: self.style.fontSize, weight: .regular)
        }
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.numberInputBackground.platformColor
        view.layer.cornerRadius = self.style.innerCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()

    lazy var textField: UITextField = {
        let view = UITextField()
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
        view.text = self.text
        view.font = self.font
        view.numberOfLines = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var dummyLabel: UILabel = {
        let view = UILabel()
        view.text = "X"
        view.font = self.font
        view.numberOfLines = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    init(_ text: String, style: NodeTextFieldStyle = .default) {
        self.text = text
        self.style = style

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = .init(width: 0, height: 2)
        self.layer.borderColor = self.style.borderColor.cgColor
        self.layer.borderWidth = 0

        self.addSubview(self.backgroundView)
        self.addSubview(self.textField)
        self.addSubview(self.label)

        self.textField.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.onTapLabel))
        tapGesture.numberOfTapsRequired = 1
        self.label.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler))
        self.addGestureRecognizer(panGesture)
    }

    @objc
    func onTapLabel() {
        self.state = .editing
    }

    @objc
    func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.onEvent?(.drag(.init(gestureRecognizerState: gesture.state), t.x, t.y))
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.label.intrinsicContentSize.max(self.dummyLabel.intrinsicContentSize)
            + self.style.textInsets.platformEdgeInsets.size
    }

    enum State {
        case idle
        case editing
    }

    var state: State = .idle {
        didSet {
            if self.state != oldValue {
                self.update()
            }
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
            self.textField.keyboardType = .decimalPad
            self.textField.isHidden = false
            self.textField.becomeFirstResponder()
            self.layer.borderWidth = self.style.borderWidth
        }
    }

    public override func layoutSubviews() {
        let size = self.intrinsicContentSize
        let rect = CGRect(origin: .zero, size: size)
        self.backgroundView.frame = rect.inset(by: self.style.backgroundInsets.platformEdgeInsets)
        self.label.frame = rect.inset(by: self.style.textInsets.platformEdgeInsets)
        self.textField.frame = rect.inset(by: self.style.textInsets.platformEdgeInsets)
    }
}

extension NodeTextFieldUIView: UITextFieldDelegate {
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
#endif
