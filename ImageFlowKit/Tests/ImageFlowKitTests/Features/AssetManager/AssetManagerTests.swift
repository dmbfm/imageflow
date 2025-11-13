import Foundation
import Testing

@testable import ImageFlowKit

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
        let id = try await am.addAsset(fromURL: url, kind: .image)
        let asset = await am.assets[id]
        #expect(asset != nil)
        #expect(asset!.id == id)
        #expect(asset!.source == .file("rethimno.png"))

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
        let _ = try await am.addAsset(fromURL: url, kind: .image)
        let _ = try await am.addAsset(fromURL: url, kind: .image)
        let _ = try await am.addAsset(fromURL: url, kind: .image)
        let id = try await am.addAsset(fromURL: url, kind: .image)
        let asset = await am.assets[id]
        #expect(asset != nil)
        #expect(asset!.id == id)
        #expect(asset!.source == .file("rethimno(4).png"))

        let assetURL = URL.tempAssetsDirectory(forDocument: documentInfo.id)
            .appending(path: "rethimno.png")

        #expect(FileManager.default.fileExists(atPath: assetURL.path))
    }

    @Test
    func clearTest() async throws {
        let am = await makeAssetManager()
        let id = try await am.addAsset(fromURL: self.fixtureImageURL, kind: .image)
        await am.clear()
        #expect(await am.assets[id] == nil)
        #expect(await am.thumbs[id] == nil)
        #expect(await am.ciImages[id] == nil)
    }

    @Test
    func restoreTest() async throws {
        let am = await makeAssetManager()
        let id = try await am.addAsset(fromURL: self.fixtureImageURL, kind: .image)
        let other = UUID()
        let asset = Asset(id: other, state: .loaded(.file("some_file.png")), added: .now, kind: .image)
        await am.restore([other: asset])
        #expect(await am.assets[id] == nil)
        #expect(await am.thumbs[id] == nil)
        #expect(await am.ciImages[id] == nil)

        #expect(await am.assets[other] == asset)
        #expect(await am.thumbs[other]!.state == .notLoaded)
        #expect(await am.ciImages[other]!.state == .notLoaded)
    }

    @Test
    func testRegisterImageAsset() async {
        let am = await makeAssetManager()
        let id = UUID()
        let asset = Asset(id: id, state: .loaded(.file("some_file.png")), added: .now, kind: .image)
        await am.registerAsset(asset)
        #expect(await am.assets[id] == asset)
        #expect(await am.thumbs[id]!.state == .notLoaded)
        #expect(await am.ciImages[id]!.state == .notLoaded)
    }

    @Test
    func testRemoveImageAsset() async throws {
        let am = await makeAssetManager()
        let url = self.fixtureImageURL
        await am.setDocumentInfo(documentInfo)
        let id = try await am.addAsset(fromURL: url, kind: .image)
        await am.removeAsset(id)
        #expect(await am.assets[id] == nil)
        #expect(await am.thumbs[id] == nil)
        #expect(await am.ciImages[id] == nil)
    }

    @Test
    func testGetThumb() async throws {
        let am = await makeAssetManager()
        let url = self.fixtureImageURL
        await am.setDocumentInfo(documentInfo)
        let id = try await am.addAsset(fromURL: url, kind: .image)
        let thumb = try await am.getThumb(forImageAsset: id)
        #expect(thumb.width == 179)
        #expect(thumb.height == 256)
    }
}
