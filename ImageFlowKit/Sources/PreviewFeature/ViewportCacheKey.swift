import Foundation
import SharedModels

struct ViewportCacheKey: Hashable {
    var location: OutputPortLocation
    // var size: CGSize

    // func hash(into hasher: inout Hasher) {
    //     hasher.combine(self.location)
    // }

    internal init(location: OutputPortLocation, size: CGSize) {
        self.location = location
        // self.size = size
    }
}
