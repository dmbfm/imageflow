@preconcurrency import CoreImage
import CubeLutKit
import Foundation
import Values

public struct NodeContext {

    let id: UUID
    let imageProvider: any BackendAssetProvider

    private let messageStore: MessageStore

    init(id: UUID, imageProvider: any BackendAssetProvider, messageStore: MessageStore) {
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
    func getLut(_ id: AssetIdentifier?) async -> CubeLut {
        guard let id else {
            return .identityRGBA
        }

        let lut: CubeLut

        do {
            lut = try await self.imageProvider.backendAssetProviderGetLut(id)
        } catch {
            lut = .identityRGBA
            self.error(.imageProvider(error))
        }

        return lut
    }

    func getImage(_ image: ImageValue) async -> CIImage? {
        guard let id = image else {
            return nil
        }

        let image: CIImage?
        do {
            image = try await self.imageProvider.backendAssetProviderGetImage(id)
        } catch {
            image = nil
            self.error(.imageProvider(error))
        }

        return image

    }

    func getImage(_ node: Node, _ input: Int) async -> CIImage? {
        await self.getImage(node.inputs[input].image)
    }

    func addImage(_ image: CIImage?, _ outputIndex: Int) async -> AssetIdentifier? {
        do {
            try await self.imageProvider.backendAssetProviderAddImage(image, node: self.id, port: outputIndex)
        } catch {
            self.error(.imageProvider(error))
            return nil
        }

        return .nodeOutput(self.id, outputIndex)
    }
}
