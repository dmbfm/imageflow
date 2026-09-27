import Foundation
import Helpers
import Testing

@testable import SharedModels

@MainActor
@Test
func testTrialManagerShouldHaveEnded() async {
    let tm = TrialManager(startDate: .now)
    tm.trialPeriod = 0.1
    try! await Task.sleep(for: .seconds(0.5))
    #expect(tm.trialEnded)
}

@MainActor
@Test
func testTrialManagerShouldNotHaveEnded() async {
    let tm = TrialManager(startDate: .now)
    tm.trialPeriod = 10.0
    try! await Task.sleep(for: .seconds(0.1))
    #expect(!tm.trialEnded)
}
