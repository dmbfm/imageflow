extension NSLayoutConstraint {
    @MainActor
    public static func activateConstraint(_ view: XView, toFill target: XView, insets: XEdgeInsets = .init(top: 0, left:  0, bottom: 0, right: 0)) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: -insets.right),
            view.topAnchor.constraint(equalTo: target.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: target.bottomAnchor, constant: -insets.bottom),
        ])
    }
}
