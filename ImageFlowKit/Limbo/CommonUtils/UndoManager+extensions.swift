//
//  UndoManager+extensions.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

import Foundation

public extension UndoManager {
    func withGroup(_ perform: () -> ()) {
        self.beginUndoGrouping()
        perform()
        self.endUndoGrouping()
    }
}
