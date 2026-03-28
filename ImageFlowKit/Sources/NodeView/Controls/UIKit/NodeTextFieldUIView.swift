#if os(iOS)

import Helpers
import SwiftUI
import Logging
import Combine

final class NodeTextFieldUIView: UIView, NodeTextFieldProtocol {

    // MARK: - Exposed Properties

    var text: String {
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

            if self.state == .idle {
                self.update()
            }
        }
    }

    var onEvent: ((NodeTextFieldEvent) -> ())?

    var style: NodeTextFieldStyle

    var placeholder: String? {
        didSet {
            self.update()
        }
    }

    var isEditable: Bool {
        get {
            self.state != .nonEditable
        }

        set {
            if !newValue {
                self.state = .nonEditable
            } else if self.state == .nonEditable {
                self.state = .idle
            }
        }
    }

    // MARK: - Private properties

    private var cancellables: Set<AnyCancellable> = []

    private var state: State = .idle {
        didSet {
            if self.state != oldValue {
                self.update()
            }
        }
    }

    enum State {
        case idle
        case editing
        case nonEditable
    }

    // MARK: - Subviews and Lazy Vars

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
        view.backgroundColor = self.style.backgroundColor
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
        view.text = "xx"
        view.font = self.font
        view.numberOfLines = 1
        view.isUserInteractionEnabled = true
        return view
    }()

    // MARK: - Init

    init(_ text: String, placeholder: String? = nil, isEditable: Bool = true, style: NodeTextFieldStyle = .default) {
        self.text = text
        self.style = style
        self.placeholder = placeholder

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

        if isEditable {
            self.state = .idle
        } else {
            self.state = .nonEditable
        }
        self.update()

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self else { return }
                if let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {

                    let maybeDuration =
                        (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
                        .doubleValue
                    let duration = maybeDuration ?? 0.4

                    let keyboardFrame = frameValue.cgRectValue
                    MainActor.assumeIsolated {
                        guard self.state == .editing else { return }
                        let bounds = self.convert(self.bounds, to: nil)
                        let dy = bounds.maxY - keyboardFrame.minY

                        if dy > 0 {
                            self.onEvent?(.keyboardWillShow(windowVerticalOverlap: dy + 10, duration: duration))
                        }
                    }
                }
            }.store(in: &self.cancellables)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updates

    func update() {
        switch self.state {
        case .idle:
            self.backgroundView.backgroundColor = self.style.backgroundColor
            self.label.isHidden = false
            self.textField.isHidden = true
            self.layer.shadowOpacity = 0
            self.layer.borderWidth = 0

            if self.label.text?.isEmpty ?? true, let placeholder = self.placeholder {
                if self.label.text != placeholder {
                    self.label.text = placeholder
                    self.label.textColor = .tertiaryLabel
                    self.resize()
                }
            } else {
                self.label.textColor = .label
            }

        case .editing:
            self.backgroundView.backgroundColor = self.style.backgroundColor
            self.label.isHidden = true
            self.textField.keyboardType = .numbersAndPunctuation
            self.textField.isHidden = false
            self.textField.becomeFirstResponder()
            self.layer.borderWidth = self.style.borderWidth
            self.label.text = self.text
            self.resize()

        case .nonEditable:
            self.label.isHidden = false
            self.textField.isHidden = true
            self.layer.shadowOpacity = 0
            self.layer.borderWidth = 0
            self.backgroundView.backgroundColor = self.style.backgroundColorNonEditable

            if self.label.text?.isEmpty ?? true, let placeholder = self.placeholder {
                if self.label.text != placeholder {
                    self.label.text = placeholder
                    self.label.textColor = .tertiaryLabel
                    self.resize()
                }
            } else {
                self.label.textColor = .label
            }
        }
    }

    @objc
    func onTextFieldChange() {
        self.label.text = self.textField.text
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        self.label.intrinsicContentSize.max(self.dummyLabel.intrinsicContentSize)
            + self.style.textInsets.platformEdgeInsets.size
    }

    public override func layoutSubviews() {
        let size = self.intrinsicContentSize
        let rect = CGRect(origin: .zero, size: size)
        self.backgroundView.frame = rect.inset(by: self.style.backgroundInsets.platformEdgeInsets)
        self.label.frame = rect.inset(by: self.style.textInsets.platformEdgeInsets)
        self.textField.frame = rect.inset(by: self.style.textInsets.platformEdgeInsets)
    }
    func resize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - User Interaction

    @objc
    func onTapLabel() {
        guard self.isEditable else { return }

        self.state = .editing
    }

    @objc
    func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        guard self.isEditable else { return }
        let t = gesture.translation(in: nil)
        let shiftDown = gesture.modifierFlags.contains(.shift)
        let optionDown = gesture.modifierFlags.contains(.alternate)
        let commandDown = gesture.modifierFlags.contains(.command)
        self.onEvent?(
            .drag(
                .init(
                    phase: .init(gestureRecognizerState: gesture.state),
                    dx: t.x,
                    dy: t.y,
                    shiftDown: shiftDown,
                    optionDown: optionDown,
                    commandDown: commandDown,
                )
            )
        )
    }

}

// MARK: - UITextFieldDelegate

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
