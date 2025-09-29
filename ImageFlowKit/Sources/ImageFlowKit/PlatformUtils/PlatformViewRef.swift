/// Holds a weak reference to a `PlatformView` (i.e., a `NSView` or a `UIView`).
@MainActor
public final class PlatformViewRef {
    /// The weak reference to the view.
    public weak var view: PlatformView?

    public init(_ view: PlatformView? = nil) {
        self.view = view
    }
}

@MainActor
public protocol PlatformViewRefStore: AnyObject {
    var view: PlatformView? { get set }
}
