import Backend
import Foundation
import Logging

@MainActor
class BackendService {

    var flow: Flow
    var assetStore: AssetStore

    init(_ flow: Flow, _ assetStore: AssetStore) {
        self.flow = flow
        self.assetStore = assetStore
    }

    func start() {
        self.observeNodes()
        self.run()
    }

    private func observeNodes() {
        withObservationTracking(
            {
                _ = self.flow.nodes
                _ = self.flow.edges
            },
            onChange: {
                Task { @MainActor in
                    self.run()
                    self.observeNodes()
                }
            }
        )
    }

    var task: Task<(), Never>? = nil
    var shouldRunAgain: Bool = false

    private func run() {
        Task {
            await self._run()
        }
    }

    var count: Int = 0
    private func _run() async {
        if self.task != nil {
            self.shouldRunAgain = true
        } else {
            self.task = Task { [weak self] in
                guard let self = self else { return }
                let startInst = ContinuousClock.now

                var backend = Backend.Flow(
                    nodes: self.flow.nodes.map { $0.value.backendNode },
                    edges: self.flow.edges.map { $0.backendEdge },
                    self.assetStore.assetManager
                )

                let messages = await backend.run()

                for node in backend.nodes {
                    for (idx, value) in node.inputs.enumerated() {
                        let input = self.flow.nodes[node.id]!.inputs[idx]

                        if input.connected && input.value != value {
                            self.flow.nodes[node.id]!.inputs[idx].value = value
                        }
                    }
                }

                let time = ContinuousClock.now - startInst

                log("Run time: \(time) [\(time * 1000) ms], messaegs: \(messages)")

                self.task = nil
            }
            await self.task!.value

            if self.shouldRunAgain {
                self.shouldRunAgain = false
                self.run()
            }
        }
    }
}
