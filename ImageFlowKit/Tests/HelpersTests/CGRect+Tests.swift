import Foundation
import Helpers
import Testing

@Test
func testCGRectCenter() {
    let rect = CGRect(x: 0, y: 0, width: 4, height: 4)

    #expect(rect.settingCenter(.zero) == .init(x: -2, y: -2, width: 4, height: 4))
    #expect(rect.settingCenterX(0) == .init(x: -2, y: 0, width: 4, height: 4))
    #expect(rect.settingCenterY(0) == .init(x: 0, y: -2, width: 4, height: 4))
}
