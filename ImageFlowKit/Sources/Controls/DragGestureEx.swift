import Helpers
import SwiftUI

#if os(macOS)
import AppKit

public struct DragGestureEx: NSGestureRecognizerRepresentable {

    var isEditable: Bool
    var handler: (Value) -> ()
    @State var startLocation: CGPoint = .zero

    public init(_ isEditable: Bool, _ handler: @escaping (Value) -> ()) {
        self.isEditable = isEditable
        self.handler = handler
    }

    public func makeNSGestureRecognizer(context: Context) -> NSPanGestureRecognizer {
        let recognizer = NSPanGestureRecognizer()
        return recognizer
    }

    public func updateNSGestureRecognizer(_ recognizer: NSPanGestureRecognizer, context: Context) {
        recognizer.isEnabled = !self.isEditable
    }

    public func handleNSGestureRecognizerAction(_ recognizer: NSPanGestureRecognizer, context: Context) {
        if recognizer.state == .began {
            self.startLocation = context.converter.location(in: .local)
        }

        self.handler(
            .init(
                phase: .init(gestureRecognizerState: recognizer.state),
                startLocation: self.startLocation,
                location: context.converter.location(in: .local),
                modifiers: recognizer.modifierFlags.eventModifiers
            )
        )
    }
}

extension NSEvent.ModifierFlags {
    var eventModifiers: EventModifiers {
        var result: EventModifiers = []
        if self.contains(.option) { result.insert(.option) }
        if self.contains(.shift) { result.insert(.shift) }
        if self.contains(.command) { result.insert(.command) }
        if self.contains(.control) { result.insert(.control) }
        if self.contains(.capsLock) { result.insert(.capsLock) }
        if self.contains(.numericPad) { result.insert(.numericPad) }
        return result
    }
}

#endif

#if os(iOS)
#endif

extension DragGestureEx {
    public struct Value: Sendable, Equatable {
        public var phase: GesturePhase
        public var startLocation: CGPoint
        public var location: CGPoint
        public var modifiers: EventModifiers
    }
}
