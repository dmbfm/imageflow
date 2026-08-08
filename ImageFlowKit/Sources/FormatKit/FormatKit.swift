import Combine
import Foundation
import Helpers

public struct DoubleFormatResolver {

    public var publisher: CurrentValueSubject<FloatingPointFormatStyle<Double>, Never>

    public var current: FloatingPointFormatStyle<Double> {
        self.publisher.value
    }

    private var cancellable: AnyCancellable?
    private var source: AnyPublisher<FloatingPointFormatStyle<Double>, Never>

    public init<P: Publisher<FloatingPointFormatStyle<Double>, Never>>(
        _ source: P,
        configuration: DoubleFormatConfiguration
    ) {
        self.source = source.eraseToAnyPublisher()
        let publisher = CurrentValueSubject<FloatingPointFormatStyle<Double>, Never>(.init())
        self.publisher = publisher
        self.cancellable = source.sink { f in
            publisher.send(configuration.apply(format: f))
        }
    }

    public func withConfiguration(_ configuration: DoubleFormatConfiguration) -> Self {
        .init(self.source, configuration: configuration)
    }

    public static func just(
        format: FloatingPointFormatStyle<Double> = .init(),
        _ configuration: DoubleFormatConfiguration
    ) -> DoubleFormatResolver {
        .init(CurrentValueSubject(format), configuration: configuration)
    }
}

public struct DoubleFormatConfiguration {
    private var _decimalSeparator: FloatingPointFormatStyle.Configuration.DecimalSeparatorDisplayStrategy?
    private var _grouping: FloatingPointFormatStyle.Configuration.Grouping?
    private var _notation: FloatingPointFormatStyle.Configuration.Notation?
    private var _precision: FloatingPointFormatStyle.Configuration.Precision?
    private var _rounded: FloatingPointFormatStyle.Configuration.RoundingRule?
    private var _sign: FloatingPointFormatStyle.Configuration.SignDisplayStrategy?

    public static var `default`: DoubleFormatConfiguration {
        .number.precision(.fractionLength(2...12))
    }

    public static var number: DoubleFormatConfiguration {
        .init()
    }

    public static var int: DoubleFormatConfiguration {
        .number.rounded().precision(.fractionLength(0))
    }

    public func decimalSeparator(
        _ value: FloatingPointFormatStyle.Configuration.DecimalSeparatorDisplayStrategy
    ) -> Self {
        var this = self
        this._decimalSeparator = value
        return this
    }

    public func grouping(
        _ value: FloatingPointFormatStyle.Configuration.Grouping
    ) -> Self {
        var this = self
        this._grouping = value
        return this
    }

    public func notation(
        _ value: FloatingPointFormatStyle.Configuration.Notation
    ) -> Self {
        var this = self
        this._notation = value
        return this
    }

    public func precision(
        _ value: FloatingPointFormatStyle.Configuration.Precision
    ) -> Self {
        var this = self
        this._precision = value
        return this
    }

    public func rounded(
        _ value: FloatingPointFormatStyle.Configuration.RoundingRule = .toNearestOrEven
    ) -> Self {
        var this = self
        this._rounded = value
        return this
    }

    public func sign(
        _ value: FloatingPointFormatStyle.Configuration.SignDisplayStrategy
    ) -> Self {
        var this = self
        this._sign = value
        return this
    }

    public func formatStyle(_ locale: Locale = .autoupdatingCurrent) -> FloatingPointFormatStyle<Double> {
        self.apply(format: .init(locale: locale))
    }

    public func apply(format: FloatingPointFormatStyle<Double>) -> FloatingPointFormatStyle<Double> {
        var result = format

        if let _decimalSeparator {
            result = result.decimalSeparator(strategy: _decimalSeparator)
        }

        if let _grouping {
            result = result.grouping(_grouping)
        }

        if let _notation {
            result = result.notation(_notation)
        }

        if let _precision {
            result = result.precision(_precision)
        }

        if let _rounded {
            result = result.rounded(rule: _rounded, increment: nil)
        }

        if let _sign {
            result = result.sign(strategy: _sign)
        }

        return result
    }
}
