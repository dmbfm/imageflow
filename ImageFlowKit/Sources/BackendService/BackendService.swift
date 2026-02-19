import Backend
import Foundation
import Helpers
import Logging
import SharedModels

import class SharedModels.Flow

@MainActor
public final class BackendService {
    var flow: Flow
    var coordinator: GlobalCoordinator
    var assetManager: any BackendAssetProvider
    var cancellables: Set<AnyEventEmitterCancellable> = []

    public init(_ flow: Flow, _ assetManager: any BackendAssetProvider, _ coordinator: GlobalCoordinator) {
        self.flow = flow
        self.assetManager = assetManager
        self.coordinator = coordinator
    }

    public func start() {
        if self.cancellables.isEmpty {
            self.flow.emitter.on { [weak self] event in
                switch event {
                case .edgesDidChange(_), .nodesDidChange(_): self?.run()
                default: break
                }
            }.store(in: &self.cancellables)
        }
        self.run()
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
                    self.assetManager
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

                log("Run time: \(time) [\(time * 1000) ms], messaegs: \(messages)", level: .info)

                self.task = nil
            }
            await self.task!.value

            self.coordinator.emitter.emit(.backendDidRun)

            if self.shouldRunAgain {
                self.shouldRunAgain = false
                self.run()
            }
        }
    }
}
