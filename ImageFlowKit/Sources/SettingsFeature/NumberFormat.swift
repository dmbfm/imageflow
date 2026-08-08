import ComponentKit
import FormatKit
import Foundation

public enum NumberFormat: Int, CaseIterable {
    case system
    case commaDot
    case noneDot
    case dotComma
    case noneComma

    var label: String {
        switch self {
        case .system: "System"
        case .commaDot: "1,234,567.89"
        case .noneDot: "1 234 567.89"
        case .dotComma: "1.234.567,89"
        case .noneComma: "1 234 567,89"
        }
    }

    var formatStyle: FloatingPointFormatStyle<Double> {
        switch self {
        case .system: .init()
        case .commaDot: .init(locale: .init(identifier: "en-US"))
        case .noneDot: .init(locale: .init(identifier: "en-US")).grouping(.never)
        case .dotComma: .init(locale: .init(identifier: "pt-BR"))
        case .noneComma: .init(locale: .init(identifier: "pt-BR")).grouping(.never)
        }
    }
}

public extension DoubleFormatResolver {
    @MainActor
    static func settingsResolver(_ configuration: DoubleFormatConfiguration) -> DoubleFormatResolver {
        .init(
            SettingsStore.shared.$numberFormat.map({ $0.formatStyle }),
            configuration: configuration
        )
    }
}

public extension NumberInput {
    convenience init(
        _ value: Double,
        settingsResolverWithFormat format: DoubleFormatConfiguration,
        stepperConfiguration: StepperConfiguration? = nil,
        style: ComponentKit::TextFieldStyle = .default
    ) {
        self.init(
            value,
            formatResolver: .settingsResolver(format),
            stepperConfiguration: stepperConfiguration,
            style: style
        )
    }
}

public extension NumberInputArray {
    convenience init(
        _ values: [Double],
        settingsResolverWithFormat format: DoubleFormatConfiguration,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        style: TextFieldStyle = .default
    ) {
        self.init(
            values,
            formatResolver: .settingsResolver(format),
            dragConfiguration: dragConfiguration,
            style: style
        )
    }
}
