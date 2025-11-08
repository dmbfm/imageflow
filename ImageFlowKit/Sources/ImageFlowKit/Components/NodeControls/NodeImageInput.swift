// import Backend
// import Helpers
// import Logging
// import SwiftUI
// import Values

// #if os(macOS)
// import AppKit

// #endif

// #if os(iOS)
// import UIKit
// #endif

// extension NodeImageInput {

//     protocol InnerView: PlatformView {
//         var vm: ViewModel { get set }
//         var onButtonClick: (() -> ())? { get set }
//         var onRemoveButtonClick: (() -> ())? { get set }

//     }

//     struct ViewModel {
//         var label: String
//         var showRemoveButton: Bool
//     }
// }

// final class NodeImageInput: PlatformCommonView, NodeControl {

//     var onEvent: ((NodeControlEvent) -> ())?

//     var value: Value {
//         didSet {
//             if self.value != oldValue {
//                 self.update()
//             }
//         }
//     }

//     var tint: PlatformColor = .systemBlue

//     var delegate: Delegate?

//     struct Delegate {
//         var openAssetBrowser: () -> ()
//         var titleForAsset: (UUID) -> String?
//     }

//     var label: String {
//         switch self.value.image {
//         case .some(.asset(let id)):
//             return self.delegate?.titleForAsset(id) ?? (id.uuidString.prefix(8) + "...")
//         case .some(.nodeOutput(let node, let index)):
//             return "node:\(node.uuidString),\(index)"
//         case .none:
//             return "Select..."
//         }
//     }

//     var showRemoveButton: Bool {
//         switch self.value.image {
//         case .none: false
//         default: true
//         }
//     }

//     var vm: ViewModel {
//         .init(label: self.label, showRemoveButton: self.showRemoveButton)
//     }

//     lazy var innerView: any InnerView = {
//         #if os(macOS)
//         let view = DefaultView(vm: self.vm)
//         #else
//         let view = GlassGroupView(vm: self.vm)
//         #endif

//         view.onButtonClick = { [weak self] in
//             self?.buttonHandler()
//         }

//         view.onRemoveButtonClick = { [weak self] in
//             self?.removeButtonHandler()
//         }

//         return view
//     }()

//     init(_ value: Value, delegate: Delegate? = nil) {
//         self.value = value
//         self.delegate = delegate

//         super.init(frame: .zero)

//         self.clipsToBounds = false

//         self.addSubview(self.innerView)

//         self.update()
//     }

//     @available(*, unavailable)
//     required init?(coder: NSCoder) {
//         nil
//     }

//     @objc
//     func buttonHandler() {
//         log("openAssetBrowser: is delegate nil? \(self.delegate == nil)")
//         self.delegate?.openAssetBrowser()
//     }

//     @objc
//     func removeButtonHandler() {
//         self.value.image = .none
//         self.emit(.valueDidChange(self.value))
//     }

//     private func update() {
//         self.innerView.vm = self.vm
//         self.setNeedsLayout()
//         self.invalidateIntrinsicContentSize()
//         self.emit(.sizeDidChange)
//     }

//     override var intrinsicContentSize: CGSize {
//         return self.innerView.intrinsicContentSize
//     }

//     override func doLayout() {
//         self.innerView.frame = .init(origin: .zero, size: self.innerView.intrinsicContentSize)
//         Layout.align(views: [self.innerView], alignment: .verticalCenter, guide: .constant(self.bounds.midY))
//     }
// }

// extension NodeImageInput {
//     fileprivate struct Preview: PlatformViewRepresentable {
//         let value: Value
//         func makeView(context: Context) -> some PlatformView {
//             NodeImageInput(
//                 value,
//                 delegate: .init(
//                     openAssetBrowser: {
//                         log("openAssetBrowser")
//                     },
//                     titleForAsset: { _ in "some_image.png" }
//                 )
//             )
//         }

//         func updateView(_ view: ViewType, context: Context) {
//         }

//         func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
//             view.intrinsicContentSize
//         }
//     }
// }

// #Preview {
//     VStack {
//         NodeImageInput.Preview(value: .image(.none))
//         NodeImageInput.Preview(value: .image(.asset(UUID())))

//         NodeView.Preview(node: .init(kind: .valueNode(.image)))

//         NodeView.Preview(node: .init(kind: .coreImageFilterNode(.colorEffect(.CIColorCube))))
//     }
//     .frame(minWidth: 500)
//     .frame(height: 500)
//     .background(Colors.canvasBackground.color)
// }
