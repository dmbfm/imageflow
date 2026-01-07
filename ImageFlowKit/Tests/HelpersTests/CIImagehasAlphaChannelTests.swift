import CoreImage
import Testing

@testable import Helpers

@Test
func testHasAlphaChannel() {
    #expect(CIImage.blue.hasAlphaChannel(nil) == nil)
    #expect(CIImage.blue.cropped(to: .init(x: 0, y: 0, width: 10, height: 10)).hasAlphaChannel(nil) == .some(false))
    #expect(
        CIImage(color: .init(red: 0, green: 0, blue: 0, alpha: 0)).cropped(to: .init(x: 0, y: 0, width: 10, height: 10))
            .hasAlphaChannel(nil) == .some(true)
    )
    #expect(
        CIImage(color: .init(red: 0, green: 0, blue: 0, alpha: 0.99)).cropped(
            to: .init(x: 0, y: 0, width: 10, height: 10)
        )
        .hasAlphaChannel(nil) == .some(true)
    )
    #expect(
        CIImage(color: .init(red: 0, green: 0, blue: 0, alpha: 1)).cropped(to: .init(x: 0, y: 0, width: 10, height: 10))
            .hasAlphaChannel(nil) == .some(false)
    )
}
