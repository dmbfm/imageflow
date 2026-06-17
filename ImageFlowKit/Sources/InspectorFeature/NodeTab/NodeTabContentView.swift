// import Combine
// import ComponentKit
// import Helpers
// import SharedModels
// import XKit

// final class NodeTabContentView: XView, Rx, WithRef {

//     var vm: NodeTabContentViewModel

//     var cancellables: Set<AnyCancellable> = []

//     lazy var scrollView: VScrollView = {
//         let view = VScrollView([], spacing: 16)
//         view.translatesAutoresizingMaskIntoConstraints = false
//         return view
//     }()

//     lazy var nodeTitleView: NodeTitleView = {
//         let view = NodeTitleView(icon: "", name: "", locked: false)
//         return view
//     }()

//     init(_ vm: NodeTabContentViewModel) {
//         self.vm = vm

//         super.init(frame: .zero)

//         self.setupViews()
//         self.setupBindings()
//     }

//     required init?(coder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//     }

//     func setupViews() {
//         self.addSubview(self.scrollView)
//         self.scrollView.constraintToFillSuperview()

//         self.scrollView.addView(self.nodeTitleView)
//     }

//     func setupBindings() {
//         self.vm.$name.assign(to: \.text, on: self.nodeTitleView.nameTextField).store(in: &self.cancellables)
//         self.vm.$locked.assign(to: \.locked, on: self.nodeTitleView).store(in: &self.cancellables)
//         self.vm.$icon.assign(to: \.icon, on: self.nodeTitleView).store(in: &self.cancellables)

//         self.nodeTitleView.lockButtonPublisher.map({ .lockClick }).receive(subscriber: self.vm)
//         self.nodeTitleView.didEditNodeName.map({ .nameEdit($0) }).receive(subscriber: self.vm)
//     }
// }
