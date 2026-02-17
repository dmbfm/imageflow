#if os(iOS)
import UIKit
extension UIView {
    public var safeAreaRect: CGRect {
        self.bounds.insetted(by: self.safeAreaInsets)
    }
}
#endif
