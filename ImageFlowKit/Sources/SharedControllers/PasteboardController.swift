#if canImport(AppKit)

import AppKit
import SharedModels
import UniformTypeIdentifiers

@MainActor
public final class PasteboardController {
    public var coordinator: GlobalCoordinator

    public init(_ coordinator: GlobalCoordinator) {
        self.coordinator = coordinator
    }

    public enum Context: Equatable {
        case canvas
        case assetBrowser

        var userActionTarget: UserAction.DropPasteImages.Target {
            switch self {
            case .assetBrowser: .assetBrowser
            case .canvas: .canvas(nil)
            }
        }
    }

    public enum DropTarget: Equatable {
        case canvas(CGPoint)
        case assetBrowser

        var userActionTarget: UserAction.DropPasteImages.Target {
            switch self {
            case .assetBrowser: .assetBrowser
            case .canvas(let point): .canvas(.canvasView(point))
            }
        }
    }

    public static let pastableTypes: [UTType] = {
        let typeIdentifiers = CGImageSourceCopyTypeIdentifiers()
        return (typeIdentifiers as? [String])?.map({ UTType($0) }).compactMap({ $0 }) ?? []
    }()

    var pastableTypes: [UTType] { Self.pastableTypes }

    var pastablePasteboardTypes: [NSPasteboard.PasteboardType] {
        self.pastableTypes.map({ .init($0.identifier) })
    }

    var pastableTypeIdentifiers: [String] {
        self.pastableTypes.map({ $0.identifier })
    }

    public func canPaste(context: Context) -> Bool {
        let pb = NSPasteboard.general

        switch context {
        case .canvas:
            let canReadFlowPasteboard = pb.canReadObject(forClasses: [FlowPasteboardItem.self])
            let canReadImageTypes = pb.canReadItem(withDataConformingToTypes: self.pastableTypeIdentifiers)

            return canReadFlowPasteboard || canReadImageTypes

        case .assetBrowser:
            return pb.canReadItem(withDataConformingToTypes: self.pastableTypeIdentifiers)
        }
    }

    public func canDrop(context: Context) -> Bool {
        let pb = NSPasteboard(name: .drag)

        if context == .canvas
            && pb.canReadItem(withDataConformingToTypes: [UTType.imageFlowNodeKindDragItem.identifier])
        {
            return true
        }

        if pb.uttypesOfURLs.contains(where: { self.pastableTypeIdentifiers.contains($0.identifier) }) {
            return true
        }

        if pb.canReadItem(withDataConformingToTypes: self.pastableTypeIdentifiers) {
            return true
        }

        return false
    }

    @discardableResult
    public func performDrop(onTarget target: DropTarget, pb: NSPasteboard) -> Bool {

        if case let .canvas(location) = target,
            let data = pb.data(forType: .init(UTType.imageFlowNodeKindDragItem.identifier)),
            let item = try? JSONDecoder().decode(NodeKindDragItem.self, from: data)
        {
            self.coordinator.perform(userAction: .newNodeWithKind(kind: item.kind, at: .canvasView(location)))
            return true
        }

        let urls = pb.urls(forTypes: self.pastableTypes)
        if !urls.isEmpty {
            self.coordinator.perform(
                userAction: .dropPasteImages(.init(payload: .url(urls), target: target.userActionTarget))
            )
            return true
        }

        if let (data, type) = pb.data(forTypes: self.pastableTypes) {
            let name = pb.string(forType: .init("public.url-name")) ?? "dropped-image"
            let filename =
                if let fileURL = pb.string(forType: .init("public.file-url")), let url = URL(string: fileURL) {
                    url.lastPathComponent
                } else if let ext = type.preferredFilenameExtension {
                    "\(name).\(ext)"
                } else {
                    "\(name)"
                }

            self.coordinator.perform(
                userAction: .dropPasteImages(
                    .init(payload: .data(.init(data: data, filename: filename)), target: target.userActionTarget)
                )
            )

        }

        return false
    }

    @discardableResult
    public func performPaste(context: Context) -> Bool {
        let pb = NSPasteboard.general

        if let nodes = NSPasteboard.general
            .readObjects(forClasses: [FlowPasteboardItem.self])?
            .map({ $0 as? FlowPasteboardItem })
            .compactMap({ $0 }), !nodes.isEmpty
        {
            self.coordinator.perform(userAction: .pasteNodes(nodes, nil))
            return true
        }

        if let (data, type) = pb.data(forTypes: self.pastableTypes) {
            let filename =
                if let ext = type.preferredFilenameExtension {
                    "clipboard-image.\(ext)"
                } else {
                    "clipboard-imae"
                }

            self.coordinator.perform(
                userAction: .dropPasteImages(
                    .init(
                        payload: .data(.init(data: data, filename: filename)),
                        target: context.userActionTarget
                    )
                )
            )

            return true
        }

        return false
    }
}

extension NSPasteboard {
    func data(forTypes types: [UTType]) -> (Data, UTType)? {
        types
            .lazy
            .map({ type in
                (self.data(forType: .init(type.identifier)), type)
            })
            .first(where: { (maybeData, type) in maybeData != nil })
            .map({ (maybeData, type) in (maybeData!, type) })
    }
}

#endif
