import SwiftUI

public extension ProposedViewSize {
    func size() -> CGSize? {
        if let width = self.width, let height = self.height {
            CGSizeMake(width, height)
        } else {
            nil
        }
    }
}
