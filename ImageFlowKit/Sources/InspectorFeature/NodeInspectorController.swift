import Backend
import Combine
import SharedModels
import SwiftUI
import XKit

class NodeInspectorController: XViewController {

    let flow: SharedModels::Flow
    var cancellables: Set<AnyCancellable> = []

    internal init(flow: SharedModels::Flow) {
        self.flow = flow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scrollView: XScrollView = {
        let view = XScrollView()
        view.documentView = self.stackView
        view.withLayer({
            $0.borderWidth = 2
            $0.borderColor = .red
        })
        view.autoresizingMask = [.width, .height]
        view.drawsBackground = false
        // view.a
        // view.contentSize = .init(width: 200, height: CGFloat)
        return view
    }()

    lazy var stackView: XStackView = {
        let view = XStackView()

        view.orientation = .vertical
        view.autoresizingMask = [.width, .height]
        view.frame = self.view.bounds
        view.edgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        view.addView(self.nodeTitleRowView, in: .top)
        view.addView(self.nodeTypeBlockView, in: .top)
        view.addView(self.dummyRowView, in: .top)

        view.setCustomSpacing(12, after: self.nodeTitleRowView)

        return view
    }()

    class DummyRowView: XViewEx {
    }

    lazy var dummyRowView: DummyRowView = {
        let view = DummyRowView()
        // view.withLayer({ $0.backgroundColor = .red })
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        return view
    }()

    lazy var nodeTitleRowView: NodeTitleRowView = {
        let view = NodeTitleRowView(icon: .systemIconLock, name: "Some Node Name", locked: false)
        return view
    }()

    lazy var nodeTypeBlockView: BlockView = {
        let view = BlockView(NSTextField(labelWithString: "Node Type"))
        return view
    }()

    lazy var contentUnavailableView: XView = {
        let view = NSHostingView(
            rootView:
                VStack {
                    Spacer()
                    Text("No Node Selected")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
        )
        view.autoresizingMask = [.width, .height]
        view.frame = self.view.bounds
        return view
    }()

    override func loadView() {
        self.view = XView()
        self.view.autoresizesSubviews = true
    }

    override func viewDidLoad() {
        self.view.addSubview(self.contentUnavailableView)
        self.view.addSubview(self.scrollView)

        self.flow.selectionDidChangePublisher.sink { [weak self] in
            self?.update()
        }.store(in: &self.cancellables)

        self.update()
    }

    func update() {
        if self.flow.selection.isEmpty {
            if self.contentUnavailableView.isHidden {
                self.contentUnavailableView.isHidden = false
            }
            if !self.scrollView.isHidden {
                self.scrollView.isHidden = true
            }
        } else {
            if !self.contentUnavailableView.isHidden {
                self.contentUnavailableView.isHidden = true
            }
            if self.scrollView.isHidden {
                self.scrollView.isHidden = false
            }
        }
    }
}
