import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit

@MainActor
public protocol XViewRepresentable: NSViewRepresentable where NSViewType == ViewType {
    associatedtype ViewType: XView

    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
    func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize?
}

extension XViewRepresentable {
    public func makeNSView(context: Context) -> NSViewType {
        self.makeView(context: context)
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        self.updateView(nsView, context: context)
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSViewType, context: Context) -> CGSize? {
        self.sizeThatFits(proposal, view: nsView, context: context)
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
        nil
    }
}

public protocol XViewControllerRepresentable: NSViewControllerRepresentable
where NSViewControllerType == ViewControllerType {
    associatedtype ViewControllerType: XViewController

    func makeViewController(context: Context) -> ViewControllerType
    func updateViewController(_ controller: ViewControllerType, context: Context)
    func sizeThatFits(_ proposal: ProposedViewSize, controller: ViewControllerType, context: Context) -> CGSize?
}

extension XViewControllerRepresentable {
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        self.makeNSViewController(context: context)
    }

    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        self.updateViewController(nsViewController, context: context)
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsViewController: NSViewControllerType,
        context: Context
    ) -> CGSize? {
        self.sizeThatFits(proposal, controller: nsViewController, context: context)
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        controller: ViewControllerType,
        context: Context
    ) -> CGSize? {
        nil
    }
}

public struct XSimpleViewControllerRepresentable: XViewControllerRepresentable {
    let controller: () -> XViewController

    public init(_ controller: @autoclosure @escaping () -> XViewController) {
        self.controller = controller
    }

    public func makeViewController(context: Context) -> XViewController {
        self.controller()
    }

    public func updateViewController(_ controller: XViewController, context: Context) {

    }
}

#endif

#if canImport(UIKit)
import UIKit

public protocol XViewRepresentable: UIViewRepresentable where UIViewType == ViewType {
    associatedtype ViewType: XView

    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
    func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize?
}

extension XViewRepresentable {
    public func makeUIView(context: Context) -> UIViewType {
        self.makeView(context: context)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        self.updateView(uiView, context: context)
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? {
        self.sizeThatFits(proposal, view: uiView, context: context)
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
        nil
    }
}

#endif

public struct XSimpleViewRepresentable: XViewRepresentable {

    let view: XView

    public init(_ view: XView) {
        self.view = view
    }

    public func makeView(context: Context) -> some NSView {
        return self.view
    }

    public func updateView(_ view: ViewType, context: Context) {

    }
}
