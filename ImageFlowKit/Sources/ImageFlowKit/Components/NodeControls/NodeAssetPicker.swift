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
    associatedtype Identifier
    static func resolve(_ value: Values.Value) -> Identifier?
    static func label(_ value: Values.Value) -> AssetPickerTypeLabel
    static var none: Value { get }
}

enum AssetPickerTypeLabel {
    case uuid(UUID)
    case other(String)
    case none
}

struct ImageAssetPicker: AssetPickerType {
    static func resolve(_ value: Value) -> ImageIdentifier? {
        value.image
    }

    static func label(_ value: Value) -> AssetPickerTypeLabel {
        switch value.image {
        case .asset(let id): .uuid(id)
        case let .nodeOutput(id, port): .other("node:\(id):\(port)")
        case .none: .none
        }
    }

    static var none: Value {
        .image(nil)
    }
}

struct LutAssetPicker: AssetPickerType {
    static func resolve(_ value: Value) -> UUID? {
        value.lut
    }

    static func label(_ value: Value) -> AssetPickerTypeLabel {
        switch value.lut {
        case .some(let id): .uuid(id)
        case .none: .none
        }
    }

    static var none: Value {
        .lut(nil)
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

    var delegate: Delegate?

    struct Delegate {
        var openAssetBrowser: () -> ()
        var titleForAsset: (UUID) -> String?
    }

    var label: String {
        switch T.label(self.value) {
        case .uuid(let id):
            self.delegate?.titleForAsset(id) ?? (id.uuidString.prefix(8) + "...")
        case .other(let label): label
        case .none: "Select..."
        }
    }

    var showRemoveButton: Bool {
        T.resolve(self.value) != nil
    }

    var vm: NodeAssetPickerInnerViewModel {
        .init(label: self.label, showRemoveButton: self.showRemoveButton)
    }

    lazy var innerView: any NodeAssetPickerInnerView = {


        #if os(macOS)
        let view = Self.DefaultView(vm: self.vm)
        #else
        #endif

        view.onButtonClick = { [weak self] in
            self?.buttonHandler()
        }

        view.onRemoveButtonClick = { [weak self] in
            self?.removeButtonHandler()
        }

        return view
    
        // fatalError("TODO")
        // #if os(macOS)
        // let view = DefaultView(vm: self.vm)
        // #else
        // // let view = GlassGroupView(vm: self.vm)
        // // #endif


        // return view
    }()

    init(_ value: Value, delegate: Delegate? = nil) {
        self.value = value
        self.delegate = delegate

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
        self.delegate?.openAssetBrowser()
    }

    @objc
    func removeButtonHandler() {
        self.value = T.none
        self.emit(.valueDidChange(self.value))
    }

    private func update() {
        self.innerView.vm = self.vm
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    override var intrinsicContentSize: CGSize {
        return self.innerView.intrinsicContentSize
    }

    override func doLayout() {
        self.innerView.frame = .init(origin: .zero, size: self.innerView.intrinsicContentSize)
        Layout.align(views: [self.innerView], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
    }
}
