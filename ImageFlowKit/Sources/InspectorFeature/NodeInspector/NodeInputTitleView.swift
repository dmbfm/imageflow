import SwiftUI
import XKit

class NodeInputTitleView: XViewEx {

    var name: String = "" {
        didSet {
            self.nameLabelView.text = name
        }
    }

    var connected: Bool = false {
        didSet {
            self.portButtonView.image = self.portButtonButtonImage
            self.portButtonView.isEnabled = self.connected
        }
    }

    var hasChanges: Bool = false {
        didSet {
            self.restoreButtonView.isHidden = !self.hasChanges
        }
    }

    var context: NodeInputControlContext?

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.portButtonView, self.nameLabelView, self.restoreButtonView])
        view.alignment = .firstBaseline
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        view.setCustomSpacing(6, after: self.nameLabelView)
        return view
    }()

    lazy var portButtonView: XButton = {
        let button = XButton(image: self.portButtonButtonImage, target: self, action: #selector(Self.portButtonHandler))
        button.isBordered = false
        button.isEnabled = self.connected
        button.contentTintColor = .system.secondaryLabel
        button.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        button.toolTip = "Select Connected Node"
        return button
    }()

    lazy var restoreButtonView: XButton = {
        let button = XButton(
            image: .init(systemSymbolName: "arrow.uturn.backward", accessibilityDescription: nil)!,
            target: self,
            action: #selector(Self.restoreButtonHandler)
        )
        button.isHidden = !self.hasChanges
        button.isBordered = false
        button.contentTintColor = .system.secondaryLabel
        button.font = .systemFont(ofSize: NSFont.systemFontSize - 2, weight: .regular)
        button.toolTip = "Restore to Default Value"
        return button
    }()

    lazy var nameLabelView: XLabel = {
        let label = XLabel(labelWithString: self.name)
        label.textColor = .system.secondaryLabel
        return label
    }()

    var portButtonButtonImage: NSImage {
        if self.connected {
            Self.connectedImage
        } else {
            Self.notConnectedImage
        }
    }

    static let connectedImage: NSImage = .init(
        systemSymbolName: "arrow.backward.circle",
        // systemSymbolName: "arrow.backward.circle.fill",
        accessibilityDescription: nil
    )!

    static let notConnectedImage: NSImage = .init(
        systemSymbolName: "circle.dotted",
        // systemSymbolName: "circle",
        accessibilityDescription: nil
    )!

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stackView)
        NSLayoutConstraint.activateConstraint(self.stackView, toFill: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func portButtonHandler() {
        self.context?.onEvent(.portButtonClicked)
    }

    @objc func restoreButtonHandler() {
        self.context?.onEvent(.restoreButtonClicked)
    }
}

#Preview {
    VStack {
        XSimpleViewRepresentable(
            {
                let view = NodeInputTitleView()
                view.name = "Intensity"
                view.hasChanges = true
                return view
            }()
        )
        .padding()
    }
}
