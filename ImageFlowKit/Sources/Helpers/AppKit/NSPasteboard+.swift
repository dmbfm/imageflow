#if canImport(AppKit)

import AppKit
import UniformTypeIdentifiers

public extension NSPasteboard {

    func urls(forTypes types: [UTType]) -> [URL] {
        self.urls.filter({ url in
            if let ty = UTType(filenameExtension: url.pathExtension) {
                types.contains(ty)
            } else {
                false
            }
        })
    }

    var urls: [URL] {
        self.readObjects(forClasses: [NSURL.self]) as? [URL] ?? []
    }

    var uttypesOfURLs: [UTType] {
        guard let urls = self.readObjects(forClasses: [NSURL.self]) as? [URL] else { return [] }

        return urls.compactMap { url in UTType(filenameExtension: url.pathExtension) }
    }
}

#endif
