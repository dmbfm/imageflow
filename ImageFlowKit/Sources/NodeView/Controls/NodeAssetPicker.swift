import Backend
import Helpers
import SharedModels
import SwiftUI
import Values
import XKit

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

@MainActor
protocol AssetPickerType: Sendable {
    static func resolve(_ value: Values.Value) -> AssetIdentifier?
    static var none: Value { get }
    static var assetKind: AssetKind { get }
}

struct ImageAssetPicker: AssetPickerType {
    static func resolve(_ value: Value) -> AssetIdentifier? {
        value.image
    }

    static var none: Value {
        .image(nil)
    }

    static var assetKind: AssetKind {
        .image
    }
}

struct LutAssetPicker: AssetPickerType {
    static func resolve(_ value: Value) -> AssetIdentifier? {
        value.lut
    }

    static var none: Value {
        .lut(nil)
    }

    static var assetKind: AssetKind {
        .lut
    }
}

protocol NodeAssetPickerInnerView: XView {
    var vm: NodeAssetPickerInnerViewModel { get set }
    var onButtonClick: (() -> ())? { get set }
    var onRemoveButtonClick: (() -> ())? { get set }
}

struct NodeAssetPickerInnerViewModel {
    var label: String
    var showRemoveButton: Bool
}

protocol NodeAssetPickerDelegate: AnyObject {
    func openAssetPicker(kind: AssetKind)
    func titleForAsset(id: AssetIdentifier) -> String?
    var emitter: EventEmitter<NodeViewDelegateEvent> { get }
}

@MainActor
final class NodeAssetPicker<T: AssetPickerType>: XViewEx, NodeControl {
    var context: NodeControlContext = .init()

    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            self.update()
        }
    }

    var tint: XColor = .systemBlue

    var cancellables: Set<AnyEventEmitterCancellable> = []

    weak var delegate: (any NodeAssetPickerDelegate)? {
        didSet {
            self.observeAssets()
        }
    }

    private var currentLabel: String = ""

    var label: String {
        let maybeID = T.resolve(self.value)
        self.currentLabel =
            switch maybeID {
            case .nodeOutput, .asset:
                self.delegate?.titleForAsset(id: maybeID!) ?? self.currentLabel
            case .none:
                "Select..."
            }
        return self.currentLabel
    }

    var showRemoveButton: Bool {
        T.resolve(self.value) != nil
    }

    var isEditable: Bool {
        didSet {
            if self.isEditable != oldValue {
                self.update()
            }
        }
    }

    var vm: NodeAssetPickerInnerViewModel {
        let vm = NodeAssetPickerInnerViewModel(label: self.label, showRemoveButton: self.showRemoveButton)
        logger.debug(
            "NodeAssetPickerInnerViewModel vm: \("\(vm)"), value: \(self.value), resolved: \("\(T.resolve(self.value), default: "nil")")"
        )
        return vm
    }

    lazy var innerView: any NodeAssetPickerInnerView = {

        #if os(macOS)
        let view = Self.DefaultView(vm: self.vm)
        #else
        let view = Self.GlassGroupView(vm: self.vm)
        #endif

        view.onButtonClick = { [weak self] in
            self?.buttonHandler()
        }

        view.onRemoveButtonClick = { [weak self] in
            self?.removeButtonHandler()
        }

        return view
    }()

    init(_ value: Value, isEditable: Bool = true, delegate: (any NodeAssetPickerDelegate)? = nil) {
        self.value = value
        self.delegate = delegate
        self.isEditable = isEditable

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.addSubview(self.innerView)

        self.observeAssets()

        self.update()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    @objc
    func buttonHandler() {
        self.delegate?.openAssetPicker(kind: T.assetKind)
    }

    @objc
    func removeButtonHandler() {
        if let undo = self.context.undo, self.value != T.none {
            undo.register(self.value, T.none)
        }
        self.value = T.none
        self.emit(.valueDidChange(self.value))
    }

    func observeAssets() {
        self.cancellables = []
        self.delegate?.emitter.on({ [weak self] _ in
            guard let self else { return }
            self.innerView.vm = self.vm
            self.update()
        }).store(in: &self.cancellables)
    }

    private func update() {
        logger.debug("NodeAssetPicker.upadate: value: \(self.value)")
        self.innerView.isHidden = !self.isEditable
        self.innerView.vm = self.vm
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    override var intrinsicContentSize: CGSize {
        return self.isEditable ? (self.innerView.intrinsicContentSize.clampWidth(to: 0...160)) : .zero
    }

    override func layout() {
        super.layout()
        self.innerView.frame = .init(origin: .zero, size: self.intrinsicContentSize)
        Layout.align(views: [self.innerView], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}
