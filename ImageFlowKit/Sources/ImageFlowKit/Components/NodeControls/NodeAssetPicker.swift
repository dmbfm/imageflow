import Backend
import Helpers
import Logging
import SwiftUI
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

protocol AssetPickerType {
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

protocol NodeAssetPickerInnerView: PlatformView {
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
}

final class NodeAssetPicker<T: AssetPickerType>: PlatformCommonView, NodeControl {

    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: PlatformColor = .systemBlue

    weak var delegate: (any NodeAssetPickerDelegate)? 

    var label: String {
        let maybeID = T.resolve(self.value)
        return switch maybeID {
        case .nodeOutput(let node, let port):
            self.delegate?.titleForAsset(id: maybeID!) ?? "[\(node):\(port)]"
        case .asset(let uuid):
            self.delegate?.titleForAsset(id: maybeID!) ?? "[\(uuid)]"
        case .none:
            "Select..."
        }
    }

    var showRemoveButton: Bool {
        switch self.value.image {
        case .asset: true
        default: false
        }
    }

    var isEditable: Bool {
        didSet {
            if self.isEditable != oldValue {
                self.update()
            }
        }
    }

    var vm: NodeAssetPickerInnerViewModel {
        .init(label: self.label, showRemoveButton: self.showRemoveButton)
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

        self.update()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    @objc
    func buttonHandler() {
        log("openAssetBrowser: is delegate nil? \(self.delegate == nil)")
        self.delegate?.openAssetPicker(kind: T.assetKind)
    }

    @objc
    func removeButtonHandler() {
        self.value = T.none
        self.emit(.valueDidChange(self.value))
    }

    private func update() {
        self.innerView.isHidden = !self.isEditable
        self.innerView.vm = self.vm
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    override var intrinsicContentSize: CGSize {
        return self.isEditable ? self.innerView.intrinsicContentSize : .zero
    }

    override func doLayout() {
        self.innerView.frame = .init(origin: .zero, size: self.innerView.intrinsicContentSize)
        Layout.align(views: [self.innerView], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}
