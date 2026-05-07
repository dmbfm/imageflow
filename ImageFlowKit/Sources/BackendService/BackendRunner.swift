import Backend
import Helpers
import OSLog
import SharedModels

let signposter = OSSignposter(subsystem: "com.dmbfm.imageflow", category: .pointsOfInterest)
let logger = Logger(subsystem: "com.dmbfm.imageflow", category: "backend-runner")

@MainActor
public final class BackendRunner {

    public var flow: SharedModels::Flow
    var cancellables: Set<AnyEventEmitterCancellable> = []
    var assetProvider: any BackendAssetProvider

    public init(_ flow: SharedModels::Flow, _ assetProvider: any BackendAssetProvider) {
        self.flow = flow
        self.assetProvider = assetProvider

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)
    }

    func onFlowEvent(_ event: SharedModels::FlowEvent) {
        switch event {
        case .nodesDidChange:
            if !self.locked {
                self.run()
            }
        default:
            break
        }
    }

    var task: Task<(), Never>?
    var needsToRunAgain: Bool = false
    var locked: Bool = false

    public func run() {
        if self.task != nil {
            self.needsToRunAgain = true
            return
        }

        let nodes = self.flow.nodes
        let edges = self.flow.edges

        self.task = Task.immediate(name: "BackendRunner", priority: .high) {
            let ss = signposter.beginInterval("BackendRunner::run::Task")
            defer { signposter.endInterval("BackendRunner::run::Task", ss) }

            let result = await self.doRun(nodes, edges, self.assetProvider)
            self.upadate(result.nodes)
            self.task = nil

            if self.needsToRunAgain {
                self.needsToRunAgain = false
                self.run()
            }
        }
    }

    @concurrent func doRun(
        _ nodes: [UUID: FlowNode],
        _ edges: Set<SharedModels::Edge>,
        _ assetProvider: any BackendAssetProvider,
    ) async -> RunResult {
        let nodes = nodes.values.map({ $0.backendNode })
        let edges = edges.map({ $0.backendEdge })
        var backend = Backend::Flow(nodes: nodes, edges: edges, assetProvider)
        let messages = await backend.run()
        return .init(messages: messages, nodes: backend.nodes)
    }

    struct RunResult: Sendable {
        var messages: [Message]
        var nodes: [Backend::Node]
    }

    func upadate(_ nodes: [Backend::Node]) {
        self.locked = true
        for node in nodes {
            for (idx, value) in node.inputs.enumerated() {
                let input = self.flow.nodes[node.id]!.inputs[idx]

                if input.connected && input.value != value {
                    self.flow.nodes[node.id]!.inputs[idx].value = value
                }
            }
        }
        self.locked = false
    }
}
