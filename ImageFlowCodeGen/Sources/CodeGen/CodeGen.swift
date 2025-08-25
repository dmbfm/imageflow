import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import Values

extension FilterInfo {
    public func gen() throws -> StructDeclSyntax {
        let structName = self.name + "Node"
        return try StructDeclSyntax("public struct \(raw: structName): NodeImplProvider") {
            try self.genImplFunction()
        }
    }

    private func genImplFunction() throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax(
            """
                public static func impl(_ param: ()) -> NodeImpl {
                    let schema = NodeSchema(
                        name: "\(raw: self.displayName)",
                        inputs: \(self.genInputsArray()),
                        outputs: [
                            .init(name: "Output Image",  type: .image)
                        ]
                    )

                    return .init(schema: schema) { node, context in
                        let filter = CIFilter(name: "\(raw: self.name)")!
                        \(self.filterAttrAssignmentsExprs())
                        node.outputs[0] = .image(await context.addImage(filter.outputImage))
                    }
                }
            """
        )
    }

    private func genInputsArray() throws -> ArrayExprSyntax {
        return ArrayExprSyntax(
            expressions: self.inputs.map { input in
                if let defaultValue = input.defaultValue {
                    return .init(
                        stringLiteral:
                            """
                            .init(name: "\(input.displayName  ?? input.name)", defaultValue: .\(input.valueType.rawValue)(\(defaultValue.expr)))
                            """
                    )
                } else {
                    return .init(
                        stringLiteral:
                            """
                            .init(name: "\(input.displayName  ?? input.name)", type: .\(input.valueType.rawValue))
                            """
                    )
                }
            }
        )
    }

    private func filterAttrAssignmentsExprs() throws -> CodeBlockItemListSyntax {
        .init() {
            for (idx, input) in self.inputs.enumerated() {
                """
                filter.setValue(\(raw: input.valueType.assignExpr("node.inputs[\(idx)]")), forKey: "\(raw: input.name)")
                """
            }
        }
    }
}

extension ValueType {
    fileprivate func assignExpr(_ base: String) -> String {
        switch self {
        case .float:
            "\(base).float"
        case .int:
            "\(base).int"
        case .bool:
            "\(base).bool"
        case .vector2:
            "\(base).vector2.ciVector"
        case .vector3:
            "\(base).vector3.ciVector"
        case .vector4:
            "\(base).vector4.ciVector"
        case .color3:
            "\(base).color3.ciColor"
        case .color4:
            "\(base).color4.ciColor"
        case .affineTransform:
            "\(base).affineTransform.fAffineTransform"
        case .attributedString:
            "NSAttributedString(\(base).attributedString)"
        case .colorSpace:
            "\(base).colorSpace.cgColorSpace()"
        case .data:
            "\(base).data"
        case .image:
            "await context.getImage(\(base).image)"
        case .rect:
            "CIVector(cgRect: \(base).rect)"
        case .string:
            "\(base).string"
        default:
            fatalError("\(self) not supported")
        }
    }
}

extension Value {

    fileprivate var expr: String {
        switch self {
        case .float(let value):
            "\(value)"
        case .int(let value):
            "\(value)"
        case .bool(let value):
            "\(value)"
        case .color3(let c):
            ".init(red: \(c.red), green: \(c.green), blue: \(c.blue))"
        case .color4(let c):
            ".init(red: \(c.red), green: \(c.green), blue: \(c.blue), alpha: \(c.alpha))"
        case .affineTransform(let t):
            ".init(m11: \(t.m11), m12: \(t.m12), m21: \(t.m21), m22: \(t.m22), tX: \(t.tX), tY: \(t.tY))"
        case .attributedString(_):
            fatalError("Not supported: \(self.type)")
        case .colorSpace(let cs):
            ".named(\"\(cs.name)\")"
        case .data(let value):
            {
                let str = value.base64EncodedString()
                return "Data(base64Encoded: \"\(str)\")!"
            }()
        case .filepath(_):
            fatalError("Not supported: \(self.type)")
        case .image(_):
            fatalError("Not supported: \(self.type)")
        case .rect(_):
            fatalError("Not supported: \(self.type)")
        case .string(let value):
            "\"\(value)\""
        case .vector2(let value):
            ".init(x: \(value.x), y: \(value.y))"
        case .vector3(let value):
            ".init(x: \(value.x), y: \(value.y), z: \(value.z))"
        case .vector4(let value):
            ".init(x: \(value.x), y: \(value.y), z: \(value.z), w: \(value.w))"
        }
    }
}

extension FilterInfoCollection {
    public func gen() throws -> SourceFileSyntax {
        return try SourceFileSyntax {
            try genIncludes()
            try genCIFilterNodeKindEnum()
            try genNodesExtension()
        }
    }

    private func genNodesExtension() throws -> ExtensionDeclSyntax {
        try .init("extension Nodes") {
            for filter in self.filters {
                try filter.gen().with(\.leadingTrivia, .newlines(2))
            }
        }
    }

    private func genIncludes() throws -> CodeBlockItemListSyntax {
        .init() {
            """

            import CoreImage
            import CoreImage.CIFilterBuiltins
            import Foundation
            import Values

            """
        }
    }

    private func genCIFilterNodeKindEnum() throws -> EnumDeclSyntax {

        let cats = FilterCategory.allCases.map { ($0, $0.rawValue.trimmingPrefix("CICategory").capitalized) }

        return try .init("public enum CIFilterNodeKind: Sendable, Hashable, Codable") {
            for (cat, catEnumName) in cats {
                "case \(raw: cat)(\(raw: catEnumName)NodeKind)"
            }

            try VariableDeclSyntax("public var impl: NodeImpl") {
                try SwitchExprSyntax("switch self") {
                    for (cat, _) in cats {
                        "case .\(raw: cat)(let kind): kind.impl"
                    }
                }
            }

            for (cat, catEnumName) in cats {
                try EnumDeclSyntax("public enum \(raw: catEnumName)NodeKind: Sendable, Hashable, Codable, CaseIterable")
                {
                    for filter in self.filters.filter({ $0.category == cat }) {
                        "case \(raw: filter.name)"
                    }

                    try VariableDeclSyntax("public var impl: NodeImpl") {
                        try SwitchExprSyntax("switch self") {
                            for filter in self.filters.filter({ $0.category == cat }) {
                                "case .\(raw: filter.name): Nodes.\(raw: filter.name)Node.impl()"
                            }
                        }
                    }
                }
            }
        }
    }
}
