import PlatformUtils
import SwiftUI
import Values

public protocol NodeControl: PlatformView {
    var tint: PlatformColor { get set }
    var value: Value { get set }
    var valueDidChange: ((Value) -> ())? { get set }
}
