import ComponentKit
import Helpers
import SharedModels
import SwiftUI
import XKit

final class GeneralTabViewController: NSViewController {

    private lazy var themeRow: ThemeRowView = {
        .init()
    }()

    private lazy var numberFormattingRow: NumberFormattingRowView = {
        .init()
    }()

    private lazy var numberDragSensitivityRow: NumberDragSensitivityRowView = {
        .init()
    }()

    private lazy var defaultPreviewLocationRowView: DefaultPreviewLocationRowView = {
        .init()
    }()

    lazy var stackView: ComponentKit::VStack = {
        let view = VStack(
            alignment: .fill,
            spacing: 12,
            views: [
                self.themeRow,
                .separator,
                self.defaultPreviewLocationRowView,
                .separator,
                self.numberDragSensitivityRow,
                self.numberFormattingRow,
            ]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)

        self.numberFormattingRow.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        return view
    }()

    override func viewDidLoad() {
        self.view.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
        ])
    }
}

private final class ThemeRowView: SettingsRegularRowView {
    override var labelText: String {
        "Appearance"
    }

    lazy var picker: PickerV2 = {
        .init(
            PreferredColorScheme.allCases.map({ .init(label: $0.displayName) }),
            selected: SettingsStore.shared.appearance.rawValue,
            style: .segmented
        )
        .with(
            \.onChange,
            { newValue in
                SettingsStore.shared.appearance = .init(rawValue: newValue) ?? .system
            }
        )
    }()

    override func height() -> CGFloat {
        max(self.labelView.intrinsicContentSize.height, self.picker.intrinsicContentSize.height)
    }

    override func makeControlView() -> XView {
        HStack(views: [
            self.picker,
            ComponentKit::Spacer(),
        ])
    }
}

private final class NumberFormattingRowView: SettingsRegularRowView {
    override var labelText: String {
        "Number Format"
    }

    lazy var picker: PickerV2 = {
        .init(
            NumberFormat.allCases.map({ .init(label: $0.label) }),
            selected: SettingsStore.shared.numberFormat.rawValue
        )
        .with(\.onChange, { SettingsStore.shared.numberFormat = .init(rawValue: $0) ?? .system })
    }()

    override func height() -> CGFloat {
        max(self.labelView.intrinsicContentSize.height, self.picker.intrinsicContentSize.height)
    }

    override func makeControlView() -> XView {
        HStack(views: [
            self.picker,
            ComponentKit::Spacer(),
        ])
    }
}

private final class DefaultPreviewLocationRowView: SettingsRegularRowView {
    override var labelText: String {
        "Default Preview Location"
    }

    lazy var picker: PickerV2 = {
        .init(
            DefaultPreviewLocation.allCases.map({ .init(label: $0.displayName, symbolName: $0.systemIcon) }),
            selected: SettingsStore.shared.defaultPreviewLocation.rawValue
        )
        .with(
            \.onChange,
            { newValue in
                SettingsStore.shared.defaultPreviewLocation = .init(rawValue: newValue) ?? .br
            }
        )
    }()

    override func height() -> CGFloat {
        max(self.labelView.intrinsicContentSize.height, self.picker.intrinsicContentSize.height)
    }

    override func makeControlView() -> XView {
        HStack(views: [
            self.picker,
            ComponentKit::Spacer(),
        ])
    }
}

private final class NumberDragSensitivityRowView: SettingsRegularRowView {
    override var labelText: String {
        "Number drag sensitivity"
    }

    lazy var themePicker: ComponentKit::Picker = {
        Picker(["Light", "Dark", "System"], selected: 2)
    }()

    override func makeControlView() -> XView {
        VanillaSlider(SettingsStore.shared.numberDragSensitivity, minValue: 0.0, maxValue: 10)
            .with(\.numberOfTickMarks, 11)
            .with(\.allowsTickMarkValuesOnly, true)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
            .with(\.onChange, { newValue in SettingsStore.shared.numberDragSensitivity = newValue })
    }
}

class SettingsRegularRowView: XView {

    var labelText: String {
        ""
    }

    var helpText: String? {
        nil
    }

    var helpTextSpacing: CGFloat {
        4.0
    }

    var labelView: XView!
    var controlView: XView!
    var heppTextView: XView?

    override var intrinsicContentSize: NSSize {
        .init(
            width: Self.noIntrinsicMetric,
            height: self.height()
        )
    }

    func height() -> CGFloat {
        var x: CGFloat = 0.0

        if let view = self.heppTextView as? NSTextField {
            let width = self.bounds.width * 0.5 - 10.0
            let cell = view.cell as! NSTextFieldCell
            let rect = cell.drawingRect(forBounds: .init(x: 0, y: 0, width: width, height: 10_000))
            let f = cell.cellSize(forBounds: rect)
            x = f.height + self.helpTextSpacing
        }

        return max(
            self.labelView.intrinsicContentSize.height + x,
            self.controlView.intrinsicContentSize.height
        )
    }

    func makeLabelView() -> XView {
        Label(self.labelText, alignment: .right)
    }

    func makeHelpTextView() -> XView? {
        self.helpText.map({
            let view = NSTextField(labelWithString: $0)
            view.font = .preferredFont(forTextStyle: .caption1)
            view.textColor = .system.secondaryLabel
            view.maximumNumberOfLines = 1000
            view.usesSingleLineMode = false
            view.lineBreakMode = .byWordWrapping
            view.alignment = .right
            view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            return view
        })
    }

    func makeControlView() -> XView {
        .init()
    }

    init() {
        super.init(frame: .zero)

        self.labelView = self.makeLabelView()
        self.controlView = self.makeControlView()

        self.labelView.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.labelView)
        self.addSubview(self.controlView)

        if let view = self.makeHelpTextView() {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            self.heppTextView = view

            NSLayoutConstraint.activate([
                self.labelView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.labelView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),
                self.labelView.topAnchor.constraint(equalTo: self.topAnchor).withPriority(.defaultLow),

                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),

                view.topAnchor.constraint(equalTo: self.labelView.bottomAnchor, constant: self.helpTextSpacing),

                self.controlView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                self.controlView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
                self.controlView.topAnchor.constraint(equalTo: self.topAnchor).withPriority(.defaultLow),

                self.labelView.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor).withPriority(
                    .defaultHigh
                ),
            ])

        } else {
            NSLayoutConstraint.activate([
                self.labelView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.labelView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),

                self.controlView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                self.controlView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),

                self.labelView.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor).withPriority(
                    .defaultHigh
                ),
            ])
        }

        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSView {
    static var separator: NSBox {
        let view = NSBox()
        view.boxType = .separator
        return view
    }
}
