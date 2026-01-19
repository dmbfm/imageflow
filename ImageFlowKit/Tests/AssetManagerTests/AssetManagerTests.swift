import Foundation
import SharedModels
import Testing

@testable import AssetManager

@Suite
final class AssetManagerTests {

    let documentInfo = DocumentInfo(id: UUID(), url: nil)

    func makeAssetManager() async -> AssetManager {
        let am = AssetManager()
        await am.setDocumentInfo(self.documentInfo)
        return am
    }

    var fixtureImageURL: URL {
        Bundle.module.url(forResource: "Fixtures/rethimno", withExtension: "png")!
    }

    init() {}

    @Test("addImageAsset(fromURL:) should copy the file to the document's asset directory.")
    func addImageAssetFromURLShouldCreateFileTest() async throws {
        let am = await makeAssetManager()
        let url = self.fixtureImageURL
        await am.setDocumentInfo(documentInfo)
        let id = try await am.importAsset(fromURL: url, kind: .image)
        let asset = await am.assets[id]
        #expect(asset != nil)
        #expect(asset!.id == id)
        #expect(asset!.filename == "rethimno.png")

        let assetURL = URL.tempAssetsDirectory(forDocument: documentInfo.id)
            .appending(path: "rethimno.png")

        #expect(FileManager.default.fileExists(atPath: assetURL.path))
    }

    @Test(
        "addImageAsset(fromURL:) with a repeated file name should add a numeric counter suffix to the new asset file."
    )
    func addImageAssetFromURLWithRepeatedNameShouldAddSuffix() async throws {
        let am = await makeAssetManager()
        let url = self.fixtureImageURL
        await am.setDocumentInfo(documentInfo)
        let _ = try await am.importAsset(fromURL: url, kind: .image)
        let _ = try await am.importAsset(fromURL: url, kind: .image)
        let _ = try await am.importAsset(fromURL: url, kind: .image)
        let id = try await am.importAsset(fromURL: url, kind: .image)
        let asset = await am.assets[id]
        #expect(asset != nil)
        #expect(asset!.id == id)
        #expect(asset!.filename == "rethimno(4).png")

        let assetURL = URL.tempAssetsDirectory(forDocument: documentInfo.id)
            .appending(path: "rethimno.png")

        #expect(FileManager.default.fileExists(atPath: assetURL.path))
    }

    @Test
    func clearTest() async throws {
        let am = await makeAssetManager()
        let id = try await am.importAsset(fromURL: self.fixtureImageURL, kind: .image)
        await am.clear()
        #expect(await am.assets[id] == nil)
    }

    @Test
    func restoreTest() async throws {
        let am = await makeAssetManager()
        let id = try await am.importAsset(fromURL: self.fixtureImageURL, kind: .image)
        let other = UUID()
        let asset = Asset(id: other, kind: .image, timestamp: .now, state: .loaded(filename: "some_file.png"))
        // let asset = Asset(id: other), state: .loaded("some_file.png"), added: .now, kind: .image)
        await am.restore(assets: [other: asset])
        #expect(await am.assets[id] == nil)
        #expect(await am.assets[other] == asset)
    }

    @Test
    func testRegisterImageAsset() async {
        let am = await makeAssetManager()
        let id = UUID()
        let asset = Asset(id: id, kind: .image, timestamp: .now, state: .loaded(filename: "some_file.png"))
        // let asset = Asset(id: .asset(id), state: .loaded(.file("some_file.png")), added: .now, kind: .image)
        await am.register(asset: asset)
        #expect(await am.assets[id] == asset)
    }

    @Test
    func testRemoveImageAsset() async throws {
        let am = await makeAssetManager()
        let url = self.fixtureImageURL
        await am.setDocumentInfo(documentInfo)
        let id = try await am.importAsset(fromURL: url, kind: .image)
        await am.remove(asset: id)
        #expect(await am.assets[id] == nil)
    }

    @Test
    func testGetThumb() async throws {
        let am = await makeAssetManager()
        let url = self.fixtureImageURL
        await am.setDocumentInfo(documentInfo)
        let id = try await am.importAsset(fromURL: url, kind: .image)
        let thumb = try await am.getAssetResource(thumbFor: id)
        #expect(thumb.width == 179)
        #expect(thumb.height == 256)
    }
}
