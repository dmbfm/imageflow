import SharedModels
import XKit

public class InspectorFeatureController: XViewController {
    public init(_ flow: Flow, _ coordinator: GlobalCoordinator) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
