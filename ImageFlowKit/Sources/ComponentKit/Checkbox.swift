import Combine
import Helpers
import XKit

public final class Checkbox: XView, Rx, WithRef {

    public var value: Bool {
        didSet {
            self.button.state = value ? .on : .off
        }
    }

    public var label: String {
        didSet {
            self.labelView.text = label
        }
    }

    public var labelPosition: LabelPosition = .after {
        didSet {
            if labelPosition != oldValue {
                self.updateLabelPosition()
            }
        }
    }

    public var onChange: ((Bool) -> ())?

    public var cancellables: Set<AnyCancellable> = []

    public enum LabelPosition: Equatable {
        case before
        case after
        case hidden
    }

    public var disabled: Bool {
        get { !self.button.isEnabled }
        set { self.button.isEnabled = !newValue }
    }

    public var button: XButton
    public var stackView: HStack!
    public var labelView: Label

    public init(_ label: String = "", value: Bool = false, onChange: ((Bool) -> ())? = nil) {
        self.label = label
        self.button = NSButton(frame: .zero)
        self.labelView = Label(label)
        self.value = value
        self.onChange = onChange

        super.init(frame: .zero)

        self.button.setButtonType(.switch)
        self.button.title = ""
        self.button.target = self
        self.button.action = #selector(Self.click)
        self.button.state = value ? .on : .off

        self.stackView = HStack(views: [
            button,
            self.labelView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)
        NSLayoutConstraint.activateConstraint(stackView, toFill: self)

        self.updateLabelPosition()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLabelPosition() {
        // NSAnimationContext.runAnimationGroup { ctx in
        // ctx.allowsImplicitAnimation = true
        self.stackView.removeAllViews()
        switch self.labelPosition {
        case .before:
            self.stackView.addView(self.labelView)
            self.stackView.addView(self.button)
        default:
            self.stackView.addView(self.button)
            self.stackView.addView(self.labelView)
        }

        self.labelView.isHidden = self.labelPosition == .hidden || self.label.isEmpty
    }

    @objc func click() {
        self.onChange?(self.button.state == .on)
    }
}

#Preview {
    {
        let p: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
        return Checkbox("Enabled") {
            print("change: \($0)")
            p.send($0)
        }
        .rx(p) { view, value in
            view.labelPosition = value ? .before : .after
        }
        // .rx(p, setFn: { view, v in
        //     view.value
        // })
    }()
}
