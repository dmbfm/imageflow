import Combine
import ComponentKit
import SettingsFeature

@MainActor
final class SensitivityResolver: DragSensitivityResolver {

    private var factor: Double = 1.0
    private var cancellables: Set<AnyCancellable> = []

    static let shared = SensitivityResolver()

    init() {
        self.factor = SettingsStore.shared.numberDragSensitivity
        SettingsStore.shared.$numberDragSensitivity.map({ $0 / 10.0 }).assign(self, \.factor).store(
            in: &self.cancellables
        )
    }

    func resolve(sensitivity: Double) -> Double {
        if self.factor < 0.5 {
            sensitivity * (self.factor + 0.5)
        } else {
            sensitivity * 2.0 * self.factor
        }
    }
}
