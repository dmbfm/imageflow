import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import Values

let semantics: [String: [String: String]] = [
    "CIDotScreen": ["inputSharpness": ".float(.range(0...1))"],
    "CIPerspectiveRotate": ["inputFocalLength": ".float(.range(15.0...100.0))"],
    "CIColorControls": [
        "inputContrast": ".float(.range(-10.0...10.0))",
        "inputBrightness": ".float(.range(-2.0...2.0))",
        "inputSaturation": ".float(.range(-20.0...20.0))",
    ],
    "CIBloom": ["inputIntensity": ".float(.range(0...1))"],
    "CIColorThreshold": ["inputThreshold": ".float(.range(0...1))"],
    "CIExposureAdjust": ["inputEV": ".float(.range(-10.0...10.0))"],
    "CIGammaAdjust": ["inputPower": ".float(.range(0.25...10.0))"],
    "CIToneMapHeadroom": [
        "inputSourceHeadroom": ".float(.range(1.0...8.0))",
        "inputTargetHeadroom": ".float(.range(1.0...8.0))",
    ],
    "CIVibrance": [
        "inputAmount": ".float(.range(-1.0...1.0))"
    ],
    "CIBokehBlur": [
        "inputRingAmount": ".float(.range(0.0...1.0))",
        "inputRingSize": ".float(.range(0.0...1.0))",
        "inputSoftness": ".float(.range(0.0...10.0))",
    ],
    "CIColorMonochrome": [
        "inputIntensity": ".float(.range(0.0...1.0))"
    ],
    "CIDither": [
        "inputIntensity": ".float(.range(0.0...1.0))"
    ],
    "CIDocumentEnhancer": [
        "inputAmount": ".float(.range(0.0...10.0))"
    ],
    "CIPinchDistortion": [
        "inputScale": ".float(.range(0.0...2.0))"
    ],
    "CIStretchCrop": [
        "inputCropAmount": ".float(.range(0.0...1.0))",
        "inputCenterStretchAmount": ".float(.range(0.0...1.0))",
    ],
    "CITorusLensDistortion": [
        "inputRefraction": ".float(.range(0.0...5.0))"
    ],
    "CIVortexDistortion": [
        "inputAngle": ".float(.default)"
    ],
    "CICMYKHalftone": [
        "inputSharpness": ".float(.range(0.0...1.0))",
        "inputGCR": ".float(.range(0.0...1.0))",
        "inputUCR": ".float(.range(0.0...1.0))",
    ],
    "CICircularScreen": [
        "inputSharpness": ".float(.range(0.0...1.0))"
    ],
    "CILineScreen": [
        "inputSharpness": ".float(.range(0.0...1.0))"
    ],
    "CIHatchedScreen": [
        "inputSharpness": ".float(.range(0.0...1.0))"
    ],
    "CISharpenLuminance": [
        "inputSharpness": ".float(.range(0.0...2.0))",
        "inputRadius": ".float(.range(0.0...20.0))",
    ],
    "CIUnsharpMask": [
        "inputIntensity": ".float(.range(0.0...1.0))"
    ],
    "CICannyEdgeDetector": [
        "inputGaussianSigma": ".float(.range(0.0...50.0))",
        "inputThresholdHigh": ".float(.range(0.0...1.0))",
        "inputThresholdLow": ".float(.range(0.0...1.0))",
        "inputHysteresisPasses": ".integer(.range(0...20))",
    ],
    "CIDepthOfField": [
        "inputSaturation": ".float(.range(0.0...10.0))",
        "inputUnsharpMaskIntensity": ".float(.range(0.0...10.0))",
    ],
    "CISpotLight": [
        "inputBrightness": ".float(.range(0.0...10.0))",
        "inputConcentration": ".float(.range(0.001...2.0))",
    ],
    "CISpotColor": [
        "inputCloseness1": ".float(.range(0.0...0.5))",
        "inputCloseness2": ".float(.range(0.0...0.5))",
        "inputCloseness3": ".float(.range(0.0...0.5))",
        "inputContrast1": ".float(.range(0.0...1.0))",
        "inputContrast2": ".float(.range(0.0...1.0))",
        "inputContrast3": ".float(.range(0.0...1.0))",
    ],
    "CILineOverlay": [
        "inputNRNoiseLevel": ".float(.range(0.0...0.1))",
        "inputNRSharpness": ".float(.range(0.0...2.0))",
        "inputThreshold": ".float(.range(0.0...1.0))",
        "inputContrast": ".float(.range(0.25...200.0))",
        "inputEdgeIntensity": ".float(.range(0.0...200.0))",
    ],
    "CIHighlightShadowAdjust": [
        "inputShadowAmount": ".float(.range(-1.0...1.0))",
        "inputHighlightAmount": ".float(.range(0.0...1.0))",
    ],
    "CIGloom": [
        "inputIntensity": ".float(.range(0.0...1.0))"
    ],
]

let addCropToSourceOptionFilters: [String] =
    [
        "CIBokehBlur",
        "CIBoxBlur",
        "CIDiscBlur",
        "CIGaussianBlur",
        "CIMaskedVariableBlur",
        "CIMotionBlur",
        "CIZoomBlur",
        "CIBumpDistortion",
        "CIGlassLozenge",
        "CIHoleDistortion",
        "CITorusLensDistortion",
        "CITwirlDistortion",
        "CIVortexDistortion",
        "CIEdgePreserveUpsampleFilter",
        "CIGuidedFilter",
        "CIPerspectiveTransformWithExtent",
        "CIDistanceGradientFromRedMask",
        "CIPointillize",
        "CIBloom",
        "CIGloom",
    ]

let forceCropToSourceFilters: [String] =
    [
        "CICircleSplashDistortion",
        "CIDroste",
        "CILightTunnel",
    ]

let inputImageNilGuardFilters: [String] =
    [
        "CINoiseReduction",
        "CIDepthToDisparity",
        "CIDisparityToDepth",
        "CIColorCrossPolynomial",
        "CIDocumentEnhancer",
        "CIGlassLozenge",
        "CITorusLensDistortion",
        "CICMYKHalftone",
        "CIPageCurlWithShadowTransition",
        "CIPageCurlTransition",
        "CITriangleTile",
        "CIOpTile",
        "CIPointillize",
        "CISpotLight",
        "CICannyEdgeDetector",
        "CIDepthOfField",
        "CIEdgeWork",
        "CIEdges",
        "CIGaborGradients",
        "CIHeightFieldFromMask",
        "CIHexagonalPixellate",
        "CILineOverlay",
        "CISobelGradients",
        "CISpotColor",
        "CISpotLight",
    ]

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
                        let outputImage = filter.outputImage
                        if let outputImage, !outputImage.extent.isEmpty {
                            \(self.nodeOutputAssignExpr())
                        } else {
                            node.outputs[0] = .image(await context.addImage(nil, 0))
                        }
                    }
                }
            """
        )
    }

    @CodeBlockItemListBuilder
    private func nodeOutputAssignExpr() throws -> CodeBlockItemListSyntax {
        if addCropToSourceOptionFilters.contains(self.name) {
            """
            if node.inputs[\(raw: self.inputs.count)].bool {
                node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
            } else {
                node.outputs[0] = .image(await context.addImage(outputImage, 0))
            }
            """
        } else if forceCropToSourceFilters.contains(self.name) {
            """
            node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
            """
        } else {
            """
            node.outputs[0] = .image(await context.addImage(outputImage, 0))
            """
        }
    }

    private func genInputsArray() throws -> ArrayExprSyntax {

        let inputs =
            if addCropToSourceOptionFilters.contains(self.name) {
                self.inputs + [
                    .init(
                        name: "cropToSource",
                        displayName: "Crop to Source",
                        description: "",
                        className: .nsNumber,
                        type: .boolean,
                        min: nil,
                        max: nil,
                        sliderMin: nil,
                        sliderMax: nil,
                        valueType: .bool,
                        defaultValue: .bool(true),
                        identity: nil,
                        editorVisibility: .inspectorOnly,
                    )
                ]
            } else {
                self.inputs
            }

        return ArrayExprSyntax(
            expressions: inputs.map { input in

                let semanticsOverride = semantics[self.name]?[input.name]
                let semanticsExpr = semanticsOverride ?? (input.type?.semanticsExpr(input) ?? ".default")

                if let defaultValue = input.defaultValue {
                    return .init(
                        stringLiteral:
                            """
                            .init(name: "\(input.displayName  ?? input.name)", defaultValue: .\(input.valueType.rawValue)(\(defaultValue.expr)), semantics: \(semanticsExpr), editorPlacement: \(input.editorVisibility.expr))
                            """
                    )
                } else {
                    return .init(
                        stringLiteral:
                            """
                            .init(name: "\(input.displayName  ?? input.name)", type: .\(input.valueType.rawValue), semantics: \(semanticsExpr), editorPlacement: \(input.editorVisibility.expr))
                            """
                    )
                }
            }
        )
    }

    private func filterAttrAssignmentsExprs() throws -> CodeBlockItemListSyntax {
        .init() {
            for (idx, input) in self.inputs.enumerated() {
                if input.valueType == .image && idx == 0
                    && (inputImageNilGuardFilters.contains(self.name)
                        || addCropToSourceOptionFilters.contains(self.name)
                        || forceCropToSourceFilters.contains(self.name))
                {
                    """
                    guard let inputImage = \(raw: input.valueType.assignExpr("node.inputs[\(idx)]")) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    """
                    if addCropToSourceOptionFilters.contains(self.name) {
                        """
                        if node.inputs[\(raw: self.inputs.count)].bool {
                            filter.setValue(inputImage.clampedToExtent(), forKey: "\(raw: input.name)")
                        } else {
                            filter.setValue(inputImage, forKey: "\(raw: input.name)")
                        }
                        """
                    } else {
                        """
                        filter.setValue(inputImage, forKey: "\(raw: input.name)")
                        """
                    }
                } else if input.valueType == .affineTransform {
                    """
                    #if os(macOS)
                    filter.setValue(\(raw: input.valueType.assignExpr("node.inputs[\(idx)]")), forKey: "\(raw: input.name)")
                    #else
                    filter.setValue(node.inputs[\(raw: idx)].affineTransform.nsValue, forKey: "\(raw: input.name)")
                    #endif
                    """
                } else {
                    """
                    filter.setValue(\(raw: input.valueType.assignExpr("node.inputs[\(idx)]")), forKey: "\(raw: input.name)")
                    """
                }
            }
        }
    }
}

extension FilterInput.EditorVisibility {
    var expr: String {
        switch self {
        case .all: ".default"
        case .inspectorOnly: ".init(nodeView: .hidden, inspector: .options)"
        }
    }
}

extension InputType {
    // var semanticsExpr: String {
    func semanticsExpr(_ input: FilterInput) -> String {
        switch self {
        case .angle:
            {
                if let min = input.sliderMin, let max = input.sliderMax {
                    return ".float(.angle(\(min)...\(max)))"
                } else {
                    return ".float(.angle(nil))"
                }
            }()
        case .boolean: ".boolean"
        case .color: ".color"
        case .count where input.valueType == .int: ".integer(.partialRangeFrom(0))"
        case .count: ".count"
        case .distance: ".distance"
        case .gradient: ".gradient"
        case .image: ".image"
        case .integer: ".integer"
        case .offset: ".offset"
        case .opaqueColor: ".opaqueColor"
        case .position: ".position2"
        case .position3: ".position3"
        case .rectangle: ".rectangle"
        case .scalar: ".default"
        case .time:
            {
                if let min = input.sliderMin, let max = input.sliderMax {
                    return ".float(.range(\(min)...\(max)))"
                } else {
                    return ".float(.default)"
                }
            }()
        case .transform: ".transform"
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
        case .lut:
            "await context.getLut(\(base).lut)"
        case .rect:
            "CIVector(cgRect: \(base).rect)"
        case .string:
            "\(base).string"
        case .matrix2x2, .matrix3x3, .matrix5x5, .matrix7x7, .floatArray:
            fatalError()
        case .gradientData:
            fatalError()
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
        case .image(_):
            fatalError("Not supported: \(self.type)")
        case .lut(_):
            fatalError("Not supported: \(self.type)")
        case .rect(let value):
            "CGRect(x: \(value.minX), y: \(value.minY), width: \(value.width), height: \(value.height))"
        case .string(let value):
            "\"\(value)\""
        case .vector2(let value):
            ".init(x: \(value.x), y: \(value.y))"
        case .vector3(let value):
            ".init(x: \(value.x), y: \(value.y), z: \(value.z))"
        case .vector4(let value):
            ".init(x: \(value.x), y: \(value.y), z: \(value.z), w: \(value.w))"
        case .matrix2x2, .matrix3x3, .matrix5x5, .matrix7x7, .floatArray:
            fatalError()
        case .gradientData(_):
            fatalError()
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
