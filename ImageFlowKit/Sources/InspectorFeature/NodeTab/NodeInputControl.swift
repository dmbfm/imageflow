import Combine
import ComponentKit
import Helpers
import SharedModels
import Values
import XKit

@MainActor
final class NodeInputControl: Rx, WithRef {

    typealias InnerView = PropertyControlView<AnyNodeInputValueControl>

    public private(set) var view: InnerView

    public var hidePortButton: Bool = false {
        didSet {
            if self.hidePortButton {
                self.view.connected = nil
            }
        }
    }

    var value: Value {
        get { self.view.control.value }
        set { self.view.control.value = newValue }
    }

    var connected: Bool {
        get { self.view.connected ?? false }
        set { self.view.connected = self.hidePortButton ? nil : newValue }
    }

    var hasChanges: Bool {
        get { self.view.hasChanges }
        set { self.view.hasChanges = newValue }
    }

    var label: String {
        get { self.view.label }
        set { self.view.label = newValue }
    }

    var disabled: Bool {
        get { false }
        set { self.view.setDisabled(newValue) }
    }

    var restoreButtonPublisher: PassthroughSubject<(), Never> {
        self.view.restoreButtonPublisher
    }

    var portButtonPublisher: PassthroughSubject<(), Never> {
        self.view.portButtonPublisher
    }

    var cancellables: Set<AnyCancellable> = []

    var changePublisher: PassthroughSubject<Change<Value>, Never> = .init()

    init(view: InnerView) {
        self.view = view
        self.view.connected = false
        self.view.hasChanges = false
    }

    init<C>(_ control: C, configuration: PropertyView.Configuration = .regular)
    where C: Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext> {
        self.view = .init(control.eraseToAnyNodeInputValueControl(), configuration: configuration)
        self.view.control.onChange = { [weak self] change in
            self?.changePublisher.send(change)
        }
    }

    public func setDisabled(_ disabled: Bool) {
        self.view.setDisabled(disabled)
    }
}

enum NodeInputControlContext {
    case float(NumericControlContext)
    case asset(AssetControlContext)
    case nothing

    var float: NumericControlContext {
        switch self {
        case .float(let ctx): ctx
        default: .default
        }
    }
}

enum NodeInputControlConfiguration {
    case float(FloatControlConfiguration)
    case angle(AngleControlConfiguration)
    case picker(PickerControlConfiguration)
    case int(IntControlConfiguration)
    case vector(VectorControlConfiguration)
    case matrix(MatrixControlConfiguration)
    case floatArray(MinMaxSliderArrayControlConfiguration)
    case nothing

    var float: FloatControlConfiguration? {
        switch self {
        case .float(let float): float
        default: nil
        }
    }

    var floatArray: MinMaxSliderArrayControlConfiguration? {
        switch self {
        case .floatArray(let floatArray): floatArray
        default: nil
        }
    }

    var int: IntControlConfiguration? {
        switch self {
        case .int(let int): int
        default: nil
        }
    }

    var angle: AngleControlConfiguration? {
        switch self {
        case .angle(let angle): angle
        default: nil
        }
    }

    var picker: PickerControlConfiguration? {
        switch self {
        case .picker(let picker): picker
        default: nil
        }
    }

    var vector: VectorControlConfiguration? {
        switch self {
        case .vector(let vector): vector
        default: nil
        }
    }

    var matrix: MatrixControlConfiguration? {
        switch self {
        case .matrix(let matrix): matrix
        default: nil
        }
    }
}

final class AnyNodeInputValueControl: Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext> {
    var value: Values.Value {
        get { self.inner.value }
        set { self.inner.value = newValue }
    }

    var context: NodeInputControlContext {
        get { self.inner.context }
        set { self.inner.context = newValue }
    }

    var configuration: NodeInputControlConfiguration {
        get { self.inner.configuration }
        set { self.inner.configuration = newValue }
    }

    var view: XView {
        self.inner.view
    }

    var auxiliaryView: XView? {
        self.inner.auxiliaryView
    }

    var onChange: ((Change<Values.Value>) -> ())? {
        get { self.inner.onChange }
        set { self.inner.onChange = newValue }
    }

    var inner: any Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext>

    init<C>(_ inner: C) where C: Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext> {
        self.inner = inner
    }

    func setDisabled(_ disabled: Bool) {
        self.inner.setDisabled(disabled)
    }
}

extension Control
where Value == Values::Value, Context == NodeInputControlContext, Configuration == NodeInputControlConfiguration {
    func eraseToAnyNodeInputValueControl() -> AnyNodeInputValueControl {
        .init(self)
    }
}

extension NodeInputControl {
    static func float(
        _ value: Value,
        _ configuration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        context: NumericControlContext = .init(statusBarMessage: { _ in })
    ) -> NodeInputControl {
        NodeInputControl(
            FloatControl.map(
                value,
                configuration: .float(.init(drag: configuration)),
                context: .float(context),
                makeControl: { value, configuration, context in
                    .init(value, configuration: configuration, context: context)
                },
                bij: .init(to: { .float($0) }, from: { $0.maybeFloat ?? 0.0 }),
                configMap: { config in
                    .init(drag: config.float?.drag ?? .free(.init()))
                },
                contextMap: { context in context.float }
            ),
            configuration: .regular
        )
    }

    static func floatArray(
        _ value: Value,
        _ configuration: MinMaxSliderArrayControlConfiguration = .init(),
    ) -> NodeInputControl {
        .init(
            MinMaxSliderArrayControl.map(
                value,
                configuration: .floatArray(configuration),
                context: .nothing,
                makeControl: { value, configuration, context in
                    MinMaxSliderArrayControl(value: value, configuration: configuration)
                },
                bij: .init(
                    to: { minMaxs in .floatArray(minMaxsToArray(minMaxs)) },
                    from: { value in arrayToMinMaxs(value.maybeFloatArray ?? []) }
                ),
                configMap: { $0.floatArray ?? .init() },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func angle(
        _ value: Value,
        range: ClosedRange<Double>?,
        context: NumericControlContext,
    ) -> NodeInputControl {
        .init(
            AngleControl.map(
                value,
                configuration: .angle(.init(range: range)),
                context: .float(context),
                makeControl: { value, configuration, context in
                    .init(value, configuration: configuration, context: context)
                },
                bij: .init(to: { .float($0) }, from: { $0.maybeFloat ?? 0.0 }),
                configMap: { .init(range: $0.angle?.range ?? nil) },
                contextMap: { $0.float }
            ),
            configuration: .regular
        )
    }

    static func bool(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            BoolControl.map(
                value,
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .bool($0) }, from: { $0.maybeBool ?? false }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .compact
        )
    }

    static func int(
        _ value: Value,
        _ range: IntControlConfiguration.Range = .none,
        context: NumericControlContext
    ) -> NodeInputControl {
        NodeInputControl(
            IntControl.map(
                value,
                configuration: .int(.init(range: range)),
                context: .float(context),
                makeControl: { value, configuration, context in
                    .init(value, configuration: configuration, context: context)
                },
                bij: .init(to: { .int($0) }, from: { $0.maybeInt ?? 0 }),
                configMap: { $0.int ?? .init(range: .none) },
                contextMap: { $0.float }
            ),
            configuration: .regular
        )
    }

    static func picker(_ value: Value, options: [String]) -> NodeInputControl {
        NodeInputControl(
            PickerControl.map(
                value,
                configuration: .picker(.init(options: options)),
                context: .nothing,
                makeControl: { value, configuration, _ in .init(value, configuration: configuration) },
                bij: .init(to: { .int($0) }, from: { $0.maybeInt ?? 0 }),
                configMap: { $0.picker ?? .init(options: []) },
                contextMap: { _ in }
            ),
            configuration: .compact
        )
    }

    static func color(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            ColorControl.map(
                value,
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in ColorControl(value) },
                bij: .init(
                    to: { .color4(.init(nsColor: $0) ?? .init(red: 0, green: 0, blue: 0, alpha: 1)) },
                    from: { $0.maybeColor4?.nsColor ?? .black }
                ),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func vector(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        labels: [String],
        bij: Bijection<[Double], Value>,
        context: NumericControlContext,
    ) -> NodeInputControl {
        return NodeInputControl(
            VectorControl.map(
                value,
                configuration: .vector(.init(drag: dragConfiguration, labels: labels)),
                context: .float(context),
                makeControl: { value, configuration, context in
                    VectorControl(value, configuration: configuration, context: context)
                },
                bij: bij,
                configMap: {
                    if let config = $0.vector {
                        return .init(drag: config.drag, labels: config.labels)
                    } else {
                        return .init(drag: dragConfiguration)
                    }
                },
                contextMap: { $0.float }
            ),
            configuration: .regular
        )
    }

    static func vector2(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        context: NumericControlContext,
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y"],
            bij: .init(
                to: { .vector2(.init(x: $0[0], y: $0[1])) },
                from: {
                    if let v = $0.maybeVector2 {
                        return [v.x, v.y]
                    } else {
                        return [0, 0]
                    }
                }
            ),
            context: context
        )
    }

    static func vector3(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        context: NumericControlContext,
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y", "z"],
            bij: .init(
                to: { .vector3(.init(x: $0[0], y: $0[1], z: $0[2])) },
                from: {
                    if let v = $0.maybeVector3 {
                        return [v.x, v.y, v.z]
                    } else {
                        return [0, 0, 0]
                    }
                }
            ),
            context: context
        )
    }

    static func vector4(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        context: NumericControlContext,
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y", "z", "w"],
            bij: .init(
                to: { .vector4(.init(x: $0[0], y: $0[1], z: $0[2], w: $0[3])) },
                from: {
                    if let v = $0.maybeVector4 {
                        return [v.x, v.y, v.z, v.w]
                    } else {
                        return [0, 0, 0, 0]
                    }
                }
            ),
            context: context
        )
    }

    static func rect(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        context: NumericControlContext,
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y", "width", "height"],
            bij: .init(
                to: { .rect(.init(x: $0[0], y: $0[1], width: $0[2], height: $0[3])) },
                from: {
                    if let r = $0.maybeRect {
                        return [r.origin.x, r.origin.y, r.size.width, r.size.height]
                    } else {
                        return [0, 0, 0, 0]
                    }
                }
            ),
            context: context
        )
    }

    static func affine(
        _ value: Value,
        configuration: MatrixControlConfiguration = .init(drag: .free(.init(fractionalDigits: 2)), formatter: .default),
        context: NumericControlContext,
    ) -> NodeInputControl {
        NodeInputControl(
            AffineTransformControl.map(
                value,
                configuration: .matrix(configuration),
                context: .float(context),
                makeControl: { value, configuration, context in
                    AffineTransformControl(value, configuration: configuration, context: context)
                },
                bij: .init(
                    to: { value in
                        .affineTransform(
                            .init(
                                m11: value[0],
                                m12: value[1],
                                m21: value[2],
                                m22: value[3],
                                tX: value[4],
                                tY: value[5]
                            )
                        )
                    },
                    from: { value in
                        let t = value.maybeAffineTransform ?? .identity
                        return [
                            t.m11,
                            t.m12,
                            t.m21,
                            t.m22,
                            t.tX,
                            t.tY,
                        ]
                    }
                ),
                configMap: { $0.matrix ?? .init() },
                contextMap: { $0.float }
            ),
            configuration: .regular
        )
    }

    static func matrix(
        _ value: Value,
        dim: Int,
        configuration: MatrixControlConfiguration = .init(drag: .free(.init(fractionalDigits: 2)), formatter: .default),
        context: NumericControlContext,
    ) -> NodeInputControl {
        NodeInputControl(
            MatrixControl.map(
                value,
                configuration: .matrix(configuration),
                context: .float(context),
                makeControl: { value, configuration, context in
                    MatrixControl(value, configuration: configuration, context: context)!
                },
                bij: .init(
                    to: { array in
                        switch dim {
                        case 2: .matrix2x2(.init(array))
                        case 3: .matrix3x3(.init(array))
                        case 5: .matrix5x5(.init(array))
                        case 7: .matrix7x7(.init(array))
                        default: .matrix2x2(.init(array))
                        }
                    },
                    from: { value in
                        switch dim {
                        case 2: value.maybeMatrix2x2?.values ?? []
                        case 3: value.maybeMatrix3x3?.values ?? []
                        case 5: value.maybeMatrix5x5?.values ?? []
                        case 7: value.maybeMatrix7x7?.values ?? []
                        default: []
                        }
                    }
                ),
                configMap: { $0.matrix ?? .init() },
                contextMap: { $0.float }
            ),
            configuration: .regular
        )
    }

    static func string(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            StringControl.map(
                value,
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .string($0) }, from: { $0.maybeString ?? "" }),
                configMap: { _ in },
                contextMap: { _ in }
            )
        )
    }

    static func fontName(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            FontNameControl.map(
                value,
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .string($0) }, from: { $0.maybeString ?? "" }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .compact
        )
    }

    static func asset(_ value: Value, assetKind: AssetKind, context: AssetControlContext) -> NodeInputControl {
        NodeInputControl(
            AssetControl.map(
                value,
                configuration: .nothing,
                context: .asset(context),
                makeControl: { value, _, context in .init(value, context: context) },
                bij: .init(
                    to: {
                        switch assetKind {
                        case .image: .image($0)
                        case .lut: .lut($0)
                        }
                    },
                    from: {
                        switch assetKind {
                        case .image: $0.maybeImage ?? .none
                        case .lut: $0.maybeLut ?? .none
                        }
                    }
                ),
                configMap: { _ in },
                contextMap: {
                    switch $0 {
                    case .asset(let asset): asset
                    default: .init(openAssetPicker: {}, titleForAsset: { _ in nil })
                    }
                }
            ),
            configuration: .compact
        )

    }

    static func gradientData(_ value: Value) -> NodeInputControl {
        .init(
            GradientDataControl.map(
                value,
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .gradientData($0) }, from: { $0.maybeGradientData ?? .default }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func staticLabel(_ value: Value) -> NodeInputControl {
        .init(
            StaticLabelControl.map(
                value,
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .string($0) }, from: { "\($0)" }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func empty() -> NodeInputControl {
        .init(
            EmptyControl.map(
                .string(""),
                configuration: .nothing,
                context: .nothing,
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .string($0) }, from: { "\($0)" }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .compact
        )
    }
}

func minMaxsToArray(_ minMaxs: [MinMax]) -> [Double] {
    var result = [Double]()
    for m in minMaxs {
        result.append(m.min)
        result.append(m.max)
    }
    return result
}

func arrayToMinMaxs(_ arr: [Double]) -> [MinMax] {
    var result = [MinMax]()
    var curr = [Double]()
    for i in arr {
        curr.append(i)
        if curr.count == 2 {
            result.append(.init(min: curr[0], max: curr[1]))
            curr.removeAll(keepingCapacity: true)
        }
    }
    return result
}
