import SwiftUI
import XKit

protocol MultiRowNodeInputControlView: BaseNodeInputControlView {
    var controlView: XView { get }
}

@MainActor
struct MultiRowNodeInputControlViewMixin {
    weak var owner: MultiRowNodeInputControlView!

    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            self.owner.titleView,
            self.owner.controlView,
        ])
        view.orientation = .vertical
        view.alignment = .leading
        return view
    }()

    init(_ owner: MultiRowNodeInputControlView) {
        self.owner = owner

        self.owner.blockView.view = self.stackView

        NSLayoutConstraint.activate([
            self.owner.controlView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.owner.controlView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.owner.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor)
        ])
    }
}
