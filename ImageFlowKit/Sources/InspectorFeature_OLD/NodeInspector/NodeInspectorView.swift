import SwiftUI
import XKit

final class NodeInspectorView: XViewEx {

    var presentedView: PresentedView = .contentUnavailable {
        didSet {
            if self.presentedView != oldValue {
                self.updatePresentedView()
            }
        }
    }

    enum PresentedView {
        case contentUnavailable
        case nodeSelected
    }

    lazy var contentUnavailableView: XView = {
        let view = NSHostingView(rootView: NoNodeSelectedView())
        view.sizingOptions = .minSize
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var nodeSelectedView: NodeSelectedView = {
        let view = NodeSelectedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.withLayer({ $0.backgroundColor = XColor.systemTeal.cgColor })
        return view
    }()

    init() {
        super.init(frame: .zero)

        // self.withLayer({
        //     $0.backgroundColor = XColor.systemRed.cgColor
        // })

        setupViews()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentContentUnavailableView() {
        self.nodeSelectedView.removeFromSuperview()
        self.addSubview(self.contentUnavailableView)
        NSLayoutConstraint.activateConstraint(self.contentUnavailableView, toFill: self)
    }

    func presentNodeSelectedView() {
        self.contentUnavailableView.removeFromSuperview()
        self.addSubview(self.nodeSelectedView)
        NSLayoutConstraint.activateConstraint(self.nodeSelectedView, toFill: self)
    }

    func setupViews() {
        self.updatePresentedView()
        //        self.addSubview(self.contentUnavailableView)
        //        self.addSubview(self.nodeSelectedView)
        //
        //        for view in self.subviews {
        //            NSLayoutConstraint.activate([
        //                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        //                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        //                view.topAnchor.constraint(equalTo: self.topAnchor),
        //                view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        //            ])
        //        }
        //        self.updatePresentedView()
    }

    func updatePresentedView() {
        switch self.presentedView {
        case .contentUnavailable:
            self.presentContentUnavailableView()
        case .nodeSelected:
            self.presentNodeSelectedView()
        }
    }
}

// MARK: - Previews

#Preview {
    VStack {
        XSimpleViewRepresentable(
            {
                let view = NodeInspectorView()
                view.presentedView = .nodeSelected
                return view
            }()
        )
        .frame(width: 320)
        .border(.red.opacity(0.12))
        .padding(50)
    }
}
