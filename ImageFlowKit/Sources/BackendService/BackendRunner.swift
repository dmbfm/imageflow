import Backend
import Helpers
import OSLog
import SharedModels

let signposter = OSSignposter(subsystem: "com.dmbfm.imageflow", category: .pointsOfInterest)
let logger = Logger(subsystem: "com.dmbfm.imageflow", category: "backend-runner")

@MainActor
public final class BackendRunner {

    public var runMode: RunMode
    var flow: SharedModels::Flow
    var coordinator: GlobalCoordinator
    var cancellables: Set<AnyEventEmitterCancellable> = []
    var assetProvider: any BackendAssetProvider

    private var task: Task<(), Never>?
    private var needsToRunAgain: Bool = false
    private var locked: Bool = false

    public enum RunMode {
        case runLoopCoalescing
        case instant
    }

    public init(
        _ flow: SharedModels::Flow,
        _ coordinator: GlobalCoordinator,
        _ assetProvider: any BackendAssetProvider,
        _ assetStore: any AssetStoreService,
        runMode: RunMode = .runLoopCoalescing
    ) {
        self.flow = flow
        self.assetProvider = assetProvider
        self.coordinator = coordinator
        self.runMode = runMode

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)

        assetStore.emitter.on({ [weak self] event in
            self?.onAssetStoreEvent(event)
        }).store(in: &self.cancellables)
    }

    func onAssetStoreEvent(_ event: AssetStoreServiceEvent) {
        switch event {
        case .assetsChanged:
            if !self.locked {
                self.runWithCurrentMode()
            }
        default:
            break
        }
    }

    func onFlowEvent(_ event: SharedModels::FlowEvent) {
        switch event {
        case .nodesDidChange:
            if !self.locked {
                self.runWithCurrentMode()
            }
        default:
            break
        }
    }

    func runWithCurrentMode() {
        switch self.runMode {
        case .instant:
            self.run()
        case .runLoopCoalescing:
            RunLoop.current.perform(inModes: [.eventTracking, .common]) {
                MainActor.assumeIsolated {
                    self.run()
                }
            }
        }
    }

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
            self.coordinator.emitter.emit(.backendDidRun)

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

            guard let flowNode = self.flow.nodes[node.id] else {
                logger.warning("Node \(node.id) is on backend but not on frontend!")
                continue
            }

            for (idx, value) in node.inputs.enumerated() {
                let input = flowNode.inputs[idx]

                if input.connected && input.value != value {
                    self.flow.nodes[node.id]?.inputs[idx].value = value
                }
            }
        }
        self.locked = false
    }
}
