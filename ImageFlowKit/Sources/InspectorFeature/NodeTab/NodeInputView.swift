import Backend
import Combine
import Helpers
import Values
import XKit

final class NodeInputView: XView, Rx, WithRef {

    let vm: NodeInputViewModel
    var cancellables: Set<AnyCancellable> = []
    var control: NodeInputControl!

    var restoreButtonPublisher: PassthroughSubject<(), Never> {
        self.control.restoreButtonPublisher
    }

    var portButtonPublisher: PassthroughSubject<(), Never> {
        self.control.portButtonPublisher
    }

    var semantics: ValueSemantics {
        didSet {
            if self.semantics != oldValue {
                self.reloadControl()
            }
        }
    }

    init(_ vm: NodeInputViewModel) {
        self.vm = vm
        self.semantics = vm.semantics
        // self.type = vm.value.type

        super.init(frame: .zero)

        self.control = self.makeControl()

        self.setupControl()
        self.setupOtherBindings()
    }

    func reloadControl() {
        self.control.view.removeFromSuperview()
        self.control = nil
        self.setupControl()
    }

    func setupControl() {
        self.control = self.makeControl()

        self.addSubview(self.control.view)
        self.control.view.translatesAutoresizingMaskIntoConstraints = false
        self.control.view.constraintToFillSuperview()

        self.setupControlBindings()
        self.setupControlNotifications()
    }

    var assetControlContext: AssetControlContext {
        .init(
            openAssetPicker: { [weak self] in
                self?.vm.receive(event: .openAssetPicker)
            },
            titleForAsset: { [weak self] id in
                self?.vm.titleForAsset(id)
            }
        )
    }

    func makeControl() -> NodeInputControl {
        switch self.vm.value.type {
        case .gradientData:
            .gradientData(self.vm.value)
        case .lut:
            .asset(
                self.vm.value,
                assetKind: .lut,
                context: self.assetControlContext
            )
        case .image:
            .asset(
                self.vm.value,
                assetKind: .image,
                context: self.assetControlContext
            )
        case .string:
            .string(self.vm.value)
        case .matrix2x2:
            .matrix(self.vm.value, dim: 2, configuration: .init(), context: self.floatControlContextContext)
        case .matrix3x3:
            .matrix(self.vm.value, dim: 3, configuration: .init(), context: self.floatControlContextContext)
        case .matrix5x5:
            .matrix(self.vm.value, dim: 5, configuration: .init(), context: self.floatControlContextContext)
        case .matrix7x7:
            .matrix(self.vm.value, dim: 7, configuration: .init(), context: self.floatControlContextContext)
        case .vector2:
            .vector2(self.vm.value, context: self.floatControlContextContext)
        case .vector3:
            .vector3(self.vm.value, context: self.floatControlContextContext)
        case .vector4:
            .vector4(self.vm.value, context: self.floatControlContextContext)
        case .rect:
            .rect(self.vm.value, context: self.floatControlContextContext)
        case .color4:
            .color(self.vm.value)
        case .int:
            switch self.vm.semantics {
            case .integer(.picker(let options)):
                .picker(self.vm.value, options: options.map({ $0.displayName }))
            case .integer(.partialRangeFrom(let minValue)):
                .int(self.vm.value, .minValue(minValue), context: self.floatControlContextContext)
            case .integer(.range(let range)):
                .int(self.vm.value, .closed(range), context: self.floatControlContextContext)
            default:
                .int(self.vm.value, .none, context: self.floatControlContextContext)
            }
        case .bool:
            .bool(self.vm.value)
        case .float:
            switch self.vm.semantics {
            case .float(.range(let range)):
                .float(
                    self.vm.value,
                    .range(.closed(.init(range: range, fractionalDigits: 2))),
                    context: self.floatControlContextContext
                )
            case .float(.angle(.some(let range))) where abs(range.span - 2.0 * .pi) < 0.001:
                .angle(self.vm.value, range: nil, context: self.floatControlContextContext)
            case .float(.angle(let maybeRange)):
                .angle(self.vm.value, range: maybeRange, context: self.floatControlContextContext)
            default:
                .float(self.vm.value, context: self.floatControlContextContext)
            }
        case .floatArray:
            switch self.vm.semantics {
            case .floatArray(.colorClamp):
                .floatArray(self.vm.value, .init())
            default:
                .staticLabel(.string(""))
            }
        default:
            {
                .staticLabel(self.vm.value)
            }()
        }
    }

    var floatControlContextContext: NumericControlContext {
        .init(statusBarMessage: { [weak self] message in
            self?.vm.receive(event: .statusBarMessage(message))
        })
    }

    func setupOtherBindings() {
        self.rx(self.vm.$semantics, kp: \.semantics)
        self.vm.$value.sink { [unowned self] value in
            if self.control.value.type != value.type {
                self.reloadControl()
            } else {
                self.control.value = value
            }
        }.store(in: &self.cancellables)
    }

    func setupControlBindings() {
        self.control.rx(self.vm.$name, kp: \.label)
        self.control.rx(self.vm.$connected, kp: \.connected)
        self.control.rx(self.vm.$hasChanges, kp: \.hasChanges)
        self.control.rx(self.vm.disabled, kp: \.disabled)
        self.control.rx(self.vm.$hidePortButton, kp: \.hidePortButton)
    }

    func setupControlNotifications() {
        self.control.changePublisher
            .map({ .valueChange($0) })
            .sendEvents(to: self.vm)
        self.control.restoreButtonPublisher
            .map({ .restoreButtonClicked })
            .sendEvents(to: self.vm)
        self.control.portButtonPublisher
            .map({ .portButtonClicked })
            .sendEvents(to: self.vm)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    NodeInputView(
        .init()
            .with(\.name, "Enabled")
            .with(\.connected, false)
            .with(\.hasChanges, false)
            .with(\.value, .bool(false))
    )
    .constrainingWidth(toConstant: 300)
}
