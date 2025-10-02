//
//  FlowNode+diff.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

extension FlowNode {
    enum DiffItem {
        case kind
        case name
        case inputs(InputsDiff)
        case outputs(OutputsDiff)
    }

    enum InputsDiff {
        case count
        case value(Int)
        case connected(Int)
    }

    enum OutputsDiff {
        case count
        case connected(Int)
    }

    func diff(_ other: Self) -> [DiffItem] {
        var result = [DiffItem]()

        if self.kind != other.kind {
            result.append(.kind)
        }

        if self.name != other.name {
            result.append(.name)
        }

        if self.inputs.count != other.inputs.count {
            result.append(.inputs(.count))
        } else {
            for i in self.inputs.indices {
                if self.inputs[i].value != other.inputs[i].value {
                    result.append(.inputs(.value(i)))
                }

                if self.inputs[i].connected != other.inputs[i].connected {
                    result.append(.inputs(.connected(i)))
                }
            }
        }

        if self.outputs.count != other.outputs.count {
            result.append(.outputs(.count))
        } else {
            for i in self.outputs.indices {
                if self.outputs[i].connected != other.outputs[i].connected {
                    result.append(.outputs(.connected(i)))
                }
            }
        }

        return result
    }
}
