//
//  UndoManager+extensions.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

import Foundation

extension UndoManager {
    public func registerUndo<V: Sendable>(withValue value: V, handler action: @escaping @MainActor (V) -> Void) {
        let box = UnsafeSendableBox(value)
        self.registerUndo(
            withTarget: box,
            handler: { _ in
                Task { @MainActor in
                    action(box.value)
                }
            }
        )
    }
}
