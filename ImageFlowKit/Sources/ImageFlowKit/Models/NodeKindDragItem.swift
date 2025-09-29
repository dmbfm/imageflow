//
//  NodeKindDragItem.swift
//  Models
//
//  Created by Daniel Fortes on 26/04/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if canImport(AppKit)
import AppKit
#endif

public extension UTType {
    static let nodeKindDragItem = UTType(exportedAs: "com.dmbfm.imageflow.node-kind")
}

public final class NodeKindDragItem: NSObject, Codable {
    public let kind: NodeKind
    public let offset: CGPoint

    public override var description: String {
        "kind: \(self.kind), offset: \(self.offset)"
    }

    public init(kind: NodeKind, offset: CGPoint = .zero) {
        self.kind = kind
        self.offset = offset
    }
}

extension NodeKindDragItem: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

extension NodeKindDragItem: NSItemProviderWriting, NSItemProviderReading {
    public static var writableTypeIdentifiersForItemProvider: [String] {
        [
            UTType.nodeKindDragItem.identifier
        ]
    }

    public func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping @Sendable (Data?, (any Error)?) -> Void
    ) -> Progress? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(self)
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }

        return nil
    }

    public static var readableTypeIdentifiersForItemProvider: [String] {
        [
            UTType.nodeKindDragItem.identifier
        ]
    }

    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()

        do {
            let item = try decoder.decode(Self.self, from: data)
            return item
        } catch {
            throw error
        }
    }
}
