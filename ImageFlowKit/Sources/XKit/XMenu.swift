import Helpers

#if canImport(AppKit)
import AppKit
public typealias XMenu = NSMenu
#endif

#if canImport(UIKit)
import UIKit
public typealias XMenu = UIMenu
#endif

public final class ClosureMenuItem: NSMenuItem, WithRef {
    var closure: () -> ()
    public init(title: String, closure: @escaping () -> ()) {
        self.closure = closure
        super.init(title: title, action: #selector(Self.handler), keyEquivalent: "")
        self.target = self
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handler() {
        self.closure()
    }
}
