import Foundation
import Helpers
import SharedModels

@MainActor
@Observable
public class MockGlobalCoordinatorService: GlobalCoordinatorService {
    public var emitter: EventEmitter<SharedModels.GlobalCoordinatorEvent> = .init()

    public var nodeSelectionCount: Int = 0

    public var canPaste: Bool = false

    public var pointerData: SharedModels.PointerData?

    public required init(flow: SharedModels.Flow) {
    }
}
