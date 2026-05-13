import Foundation

struct WindowPreviewCache: Sendable, Equatable {
    private var cache: Entry? = nil

    struct Entry: Sendable, Equatable {
        var viewport: CGRect
        var windowFrame: CGRect
    }

    init() {

    }

    func get() -> Entry? {
        self.cache
    }

    mutating func set(_ value: Entry) {
        self.cache = value
    }

    mutating func clear() {
        self.cache = nil
    }

    mutating func update(_ f: (Entry?) -> (Entry?)) {
        self.cache = f(self.cache)
    }
}
