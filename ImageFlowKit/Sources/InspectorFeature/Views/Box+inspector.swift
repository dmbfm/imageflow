import ComponentKit
import SwiftUI
import XKit

extension Box {
    convenience init(inspectorBlockWithView view: XView) {
        self.init(view: view)
        self.cornerRadius = 10
        self.cornerCurve = .continuous
        self.insets = .init(10)
        self.borderColor = nil
    }
}
