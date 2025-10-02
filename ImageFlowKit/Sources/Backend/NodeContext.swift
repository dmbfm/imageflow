@preconcurrency import CoreImage
import Foundation
import Values

public struct NodeContext {

    let id: UUID
    let imageProvider: any FlowImageProvider

    private let messageStore: MessageStore

    init(id: UUID, imageProvider: any FlowImageProvider, messageStore: MessageStore) {
        self.id = id
        self.imageProvider = imageProvider
        self.messageStore = messageStore
    }

    func message(_ message: NodeMessage) {
        self.messageStore.messages.append(message.message(withNodeID: self.id))
    }

    func error(_ content: Message.Content, scope: NodeMessage.Scope = .node) {
        self.message(.init(content: content, scope: scope, level: .error))
    }
}

// MARK: - Filter Node Helpers
extension NodeContext {
    func getImage(_ image: ImageValue) async -> CIImage? {
        guard let id = image else {
            return nil
        }

        let image: CIImage?
        do {
            image = try await self.imageProvider.getImage(id)
        } catch {
            image = nil
            self.error(.imageProvider(error))
        }

        return image

    }

    func getImage(_ node: Node, _ input: Int) async -> CIImage? {
        await self.getImage(node.inputs[input].image)
    }

    func addImage(_ image: CIImage?, id: ImageIdentifier? = nil) async -> ImageIdentifier? {
        guard let image else { return nil }

        do {
            return try await self.imageProvider.addImage(image, id: id)
        } catch {
            self.error(.imageProvider(error))
            return nil
        }
    }
}
