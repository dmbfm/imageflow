#if os(iOS)

import UIKit

extension UIColor {
    public convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                dark
            case .light, .unspecified:
                light
            @unknown default:
                light
            }
        })
    }
}

#endif
