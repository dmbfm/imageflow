import Combine
import Helpers
import SharedModels
import SwiftUI
import XKit

class NodeInspectorController: XViewController {

    // MARK: - Properties

    let flow: Flow

    private var cancellables: Set<AnyCancellable> = []

    private var vm: NodeInspectorViewModel = .empty {
        didSet {
            logger.debug("vm didSet: \("\(oldValue)") -> \("\(self.vm)")")
            if self.vm != oldValue {
                self.updateView()
            }
        }
    }

    // MARK: - Views

    lazy var emptyView: XView = {
        let view = NodeInspectorEmtpyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var contentView: NodeInspectorContentView = {
        let view = NodeInspectorContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    init(_ flow: Flow) {
        self.flow = flow

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func viewDidLoad() {
        self.setupViews()
        self.setupObservers()
        self.updateView()
    }

    func setupViews() {
        for subview in [emptyView, contentView] {
            self.view.addSubview(subview)
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                subview.topAnchor.constraint(equalTo: self.view.topAnchor),
            ])
        }
    }

    func setupObservers() {
        self.flow.selectionDidChangePublisher.sink { [weak self] in
            self?.selectionDidChange()
        }.store(in: &self.cancellables)
    }

    // MARK: - State updates

    func selectionDidChange() {
        self.vm.update(.selection(nodes: self.flow.nodes, selection: self.flow.selection))
    }

    // MARK: - View updates

    func updateView() {
        switch self.vm {
        case .empty:
            self.showEmptyView()
        case .content(_, _, _):
            self.showContentView()
        }
    }

    func showEmptyView() {
        if !self.contentView.isHidden {
            self.contentView.isHidden = true
        }
        if self.emptyView.isHidden {
            self.emptyView.isHidden = false
        }
    }

    func showContentView() {
        if self.contentView.isHidden {
            self.contentView.isHidden = false
        }
        if !self.emptyView.isHidden {
            self.emptyView.isHidden = true
        }
    }
}
