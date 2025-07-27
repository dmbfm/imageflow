import AppKit
import AppKitUtils
import CanvasFeature
import CanvasView
import Logging
import SwiftUI
import Synchronization
import UniformTypeIdentifiers

struct FlowDoc: FileDocument, Codable, Equatable {

    var canvasStore: CanvasFeature.StoredState = .init()

    static var readableContentTypes: [UTType] {
        [.imageFlowDocument]
    }

    init(configuration: ReadConfiguration) throws {
        log("loading...")
        guard let wrappers = configuration.file.fileWrappers else {
            fatalError()
        }

        guard let data = wrappers["flow.json"]?.regularFileContents else {
            fatalError()
        }

        self.canvasStore = try JSONDecoder().decode(CanvasFeature.StoredState.self, from: data)
    }

    init() {}

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        log("saving...")
        let data = try JSONEncoder().encode(self.canvasStore)
        let result = FileWrapper(directoryWithFileWrappers: ["flow.json": FileWrapper(regularFileWithContents: data)])
        log("done!")
        return result
    }
}

// extension FlowDoc: AssetImageSource {
//     func get(image id: UUID) -> CGImage? {
//         self.assets[id]
//     }
// }

// protocol AssetImageSource {
//     func get(image id: UUID) -> CGImage?
// }

// actor AssetManager {
//     init(source: any AssetImageSource) {
//         self.source = source
//     }

//     var source: (AssetImageSource)
// }
