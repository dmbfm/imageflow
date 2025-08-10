//
//  Design.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 09/08/25.
//

import Foundation
import PlatformUtils
import CoreGraphics

struct Design {
    var portSize: CGFloat
    var portStrokeWidth: CGFloat = 1.0
    var portLabelSpacing: CGFloat = 8.0
    var labelControlSpacing: CGFloat = 8.0
    var shadowColor: CGColor = .init(gray: 0, alpha: 0.4)
    var shadowRadius: CGFloat = 4
    var shadowOffset: CGSize = .init(width: 0, height: 2)
    var shadowOpacity: Float = 1
    var titleLeft: CGFloat = 16
    var titleTop: CGFloat = 14
    var titleBottom: CGFloat = 8
    var titleRight: CGFloat = 26
    var nodeRowHeight: CGFloat = 32
    var inputBlockBottomPadding: CGFloat = 10
    var outputBlockBottomPadding: CGFloat = 10
    
    static var iOS: Self {
        .init(portSize: 12, portStrokeWidth: 1)
    }
    
    static var macOS: Self {
        .init(portSize: 8)
    }
    
    #if os(macOS)
    static let `default`: Self = .macOS
    #endif
    
    #if os(iOS)
    static let `default`: Self = .iOS
    #endif
}

#if os(iOS)
import UIKit
extension UILabel {
    convenience init(nodeRowLabelWithString text: String) {
        self.init()
        self.text = text
        self.font = .preferredFont(forTextStyle: .body)
    }
}
#endif
