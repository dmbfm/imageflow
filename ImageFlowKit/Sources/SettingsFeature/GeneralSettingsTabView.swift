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
            spacing: 16,
            views: [
                self.themeRow,
                self.defaultPreviewLocationRowView,
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
        // .withRef({ $0.inner. })
    }()

    override func makeControlView() -> XView {
        // ComponentKit::HStack(views: [
        VanillaSlider(SettingsStore.shared.numberDragSensitivity, minValue: 0.0, maxValue: 10)
            .with(\.numberOfTickMarks, 11)
            .with(\.allowsTickMarkValuesOnly, true)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
            .with(\.onChange, { newValue in SettingsStore.shared.numberDragSensitivity = newValue })
        //         .constrainingWidth(toConstant: 180),
        //     Spacer(),
        // ])
    }
}

class SettingsRegularRowView: XView {

    var labelText: String {
        ""
    }

    var labelView: XView!
    var controlView: XView!

    override var intrinsicContentSize: NSSize {
        .init(
            width: Self.noIntrinsicMetric,
            height: self.height()
        )
    }

    func height() -> CGFloat {
        max(self.labelView.intrinsicContentSize.height, self.controlView.intrinsicContentSize.height)
    }

    func makeLabelView() -> XView {
        Label(self.labelText, alignment: .right)
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

        NSLayoutConstraint.activate([
            self.labelView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.labelView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),

            self.controlView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.controlView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),

            self.labelView.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor).withPriority(
                .defaultHigh
            ),
        ])

        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
