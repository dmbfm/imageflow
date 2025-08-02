import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

#if os(macOS)
public protocol PlatformViewRepresentable: NSViewRepresentable where NSViewType == ViewType {

    associatedtype ViewType: PlatformView

    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
}

public extension PlatformViewRepresentable {
    func makeNSView(context: Context) -> NSViewType {
        self.makeView(context: context)
    }

    func updateNSView(_ view: ViewType, context: Context) {
        self.updateView(view, context: context)
    }
}
#endif

#if os(iOS)
public protocol PlatformViewRepresentable: UIViewRepresentable where UIViewType == ViewType {

    associatedtype ViewType: PlatformView

    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
}
public extension PlatformViewRepresentable {
    func makeUIView(context: Context) -> UIViewType {
        self.makeView(context: context)
    }

    func updateUIView(_ view: ViewType, context: Context) {
        self.updateView(view, context: context)
    }
}
#endif
