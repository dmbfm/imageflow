import AppKit
import ComponentKit
import Helpers

final class AboutTabViewController: NSViewController {

    lazy var logoImage: NSImage = {
        Bundle.module.image(forResource: "logo")!
    }()

    lazy var logoView: NSView = {
        let imageflowLabel = Label("ImageFlow", font: .preferredFont(forTextStyle: .headline), alignment: .center)
            .withContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        let imageView: NSImageView = {
            let view = NSImageView(image: self.logoImage)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.imageScaling = .scaleProportionallyUpOrDown
            view.imageAlignment = .alignCenter
            view.constrainingHeight(toConstant: 150)
            return view
        }()
        let appVersion = (Bundle.main.infoDictionary?["CFBundleVersionString"] as? String) ?? "1.0.0"
        return VStack(
            alignment: .fill,
            views: [
                Spacer().constrainingHeight(toConstant: 10),
                imageView,
                imageflowLabel,
                Label("Version: \(appVersion)", font: .preferredFont(forTextStyle: .caption1), alignment: .center),
                Spacer(),
            ]
        )
        .withRef({
            $0.setCustomSpacing(2, after: imageflowLabel)
            $0.setCustomSpacing(0, after: imageView)
        })
    }()

    lazy var rightSideView: VStack = {
        return VStack(
            alignment: .fill,
            spacing: 16,
            views: [
                VStack(
                    alignment: .fill,
                    spacing: 0,
                    views: [
                        Label("Daniel Fortes").with(\.font, .boldSystemFont(ofSize: 12)).with(\.alignment, .center),
                        Label("Design and Development").with(\.font, .systemFont(ofSize: 12)).with(
                            \.alignment,
                            .center
                        ),
                    ]
                ),
                VStack(
                    alignment: .fill,
                    spacing: 0,
                    views: [
                        Label("Matthew Skiles").with(\.font, .boldSystemFont(ofSize: 12)).with(\.alignment, .center),
                        Label("Icon Design").with(\.font, .systemFont(ofSize: 12)).with(\.alignment, .center),
                    ]
                ),
                Spacer(),
                VStack(
                    alignment: .fill,
                    spacing: 2,
                    views: [
                        {
                            let view = NSButton()
                            view.title = "Open Source Licenses"
                            view.target = self
                            view.action = #selector(Self.showOpenSourceLicenses)
                            view.font = .systemFont(ofSize: 12)
                            view.contentTintColor = .systemBlue
                            view.isBordered = false
                            return view
                        }(),
                        {
                            let view = NSButton()
                            view.title = "Privacy Policy"
                            view.target = self
                            view.action = #selector(Self.showOpenSourceLicenses)
                            view.font = .systemFont(ofSize: 12)
                            view.contentTintColor = .systemBlue
                            view.isBordered = false
                            return view
                        }(),

                    ]
                ),
                VStack(
                    alignment: .fill,
                    spacing: 4,
                    views: [
                        Button("Visit Website") {
                            NSWorkspace.shared.open(
                                .init(string: "https://www.imageflowapp.com")!
                            )
                        },
                        Button("Open Documentation") {
                            NSWorkspace.shared.open(
                                .init(string: "https://docs.imageflowapp.com")!
                            )
                        },
                        Button("Contact Support") {
                            NSWorkspace.shared.open(
                                .init(string: "mailto:support@imageflowapp.com")!
                            )
                        },
                    ]
                ),
            ]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    @objc func showOpenSourceLicenses() {
        NSWorkspace.shared.open(.init(string: "https://docs.imageflowapp.com/open-source-licenses")!)
    }

    lazy var separator: NSView = {
        let view = NSBox()
        view.boxType = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        view.constrainingWidth(toConstant: 1)
        return view
    }()

    override func viewDidLoad() {
        self.view.widthAnchor.constraint(equalToConstant: 480).withPriority(.defaultHigh).isActive = true
        self.logoView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.separator)
        self.view.addSubview(self.rightSideView)

        NSLayoutConstraint.activate([
            self.logoView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            self.logoView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.logoView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            self.logoView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor, constant: -20),
            // self.logoView.heightAnchor.constraint(equalToConstant: 100),

            self.separator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.separator.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.separator.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),

            // self.rightSideView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.rightSideView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.rightSideView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            self.rightSideView.leadingAnchor.constraint(
                equalTo: self.view.layoutMarginsGuide.centerXAnchor,
                constant: 20
            ),
            self.rightSideView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}
