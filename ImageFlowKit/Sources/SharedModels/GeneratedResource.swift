//
//  GeneratedResource.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 19/01/26.
//

import Foundation

public struct GeneratedResource<T>: Identifiable {
    public var id: OutputPortLocation
    public var timestamp: Date
    public var res: T

    public init(id: OutputPortLocation, timestamp: Date, res: T) {
        self.id = id
        self.timestamp = timestamp
        self.res = res
    }
}

extension GeneratedResource: Sendable where T: Sendable {}
