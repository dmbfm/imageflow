@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation
import Values

extension Decodable {
    init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        if let value = try? JSONDecoder().decode(Self.self, from: data) {
            self = value
        } else {
            return nil
        }
    }
}

public enum CIFilterNodeKind: Sendable, CaseIterable, Equatable, Codable {
    case accordionFoldTransition
    case affineClamp
    case affineTile
    case areaAverage
    case areaBoundsRed
    case areaHistogram
    case areaLogarithmicHistogram
    case areaMaximum
    case areaMaximumAlpha
    case areaMinMax
    case areaMinMaxRed
    case areaMinimum
    case areaMinimumAlpha
    case attributedTextImageGenerator
    case barsSwipeTransition
    case bicubicScaleTransform
    case blendWithRedMask
    case bloom
    case blurredRectangleGenerator
    case bokehBlur
    case boxBlur
    case bumpDistortion
    case bumpDistortionLinear
    case cannyEdgeDetector
    case checkerboardGenerator
    case circleSplashDistortion
    case circularScreen
    case circularWrap
    case cmykHalftone
    case code128BarcodeGenerator
    case colorAbsoluteDifference
    case colorClamp
    case colorControls
    case colorCrossPolynomial
    case colorCube
    case colorCubeWithColorSpace
    case colorCubesMixedWithMask
    case colorCurves
    case colorInvert
    case colorMap
    case colorMatrix
    case colorMonochrome
    case colorPolynomial
    case colorPosterize
    case colorThreshold
    case colorThresholdOtsu
    case columnAverage
    case comicEffect
    case convertRGBtoLab
    case convolutionRGB9Vertical
    case copyMachineTransition
    case crystallize
    case depthOfField
    case depthToDisparity
    case discBlur
    case disintegrateWithMaskTransition
    case disparityToDepth
    case displacementDistortion
    case dissolveTransition
    case dither
    case documentEnhancer
    case dotScreen
    case droste
    case edgePreserveUpsample
    case edgeWork
    case edges
    case eightfoldReflectedTile
    case exposureAdjust
    case falseColor
    case flashTransition
    case fourfoldReflectedTile
    case fourfoldRotatedTile
    case fourfoldTranslatedTile
    case gaborGradients
    case gammaAdjust
    case gaussianBlur
    case gaussianGradient
    case glassDistortion
    case glassLozenge
    case glideReflectedTile
    case gloom
    case hatchedScreen
    case heightFieldFromMask
    case hexagonalPixellate
    case highlightShadowAdjust
    case histogramDisplay
    case holeDistortion
    case hueAdjust
    case hueSaturationValueGradient
    case kMeans
    case kaleidoscope
    case keystoneCorrectionCombined
    case keystoneCorrectionHorizontal
    case keystoneCorrectionVertical
    case labDeltaE
    case lanczosScaleTransform
    case lenticularHaloGenerator
    case lightTunnel
    case lineOverlay
    case lineScreen
    case linearGradient
    case linearToSRGBToneCurve
    case maskToAlpha
    case maskedVariableBlur
    case maximumComponent
    case maximumScaleTransform
    case median
    case minimumComponent
    case mix
    case modTransition
    case morphologyGradient
    case morphologyMaximum
    case morphologyMinimum
    case morphologyRectangleMaximum
    case morphologyRectangleMinimum
    case motionBlur
    case ninePartStretched
    case ninePartTiled
    case noiseReduction
    case opTile
    case pageCurlTransition
    case pageCurlWithShadowTransition
    case paletteCentroid
    case palettize
    case parallelogramTile
    case personSegmentation
    case perspectiveCorrection
    case perspectiveRotate
    case perspectiveTile
    case perspectiveTransform
    case perspectiveTransformWithExtent
    case photoEffectTransfer
    case pinchDistortion
    case pixellate
    case pointillize
    case qrCodeGenerator
    case radialGradient
    case randomGenerator
    case rippleTransition
    case roundedRectangleGenerator
    case roundedRectangleStrokeGenerator
    case rowAverage
    case sRGBToneCurveToLinear
    case saliencyMap
    case sepiaTone
    case shadedMaterial
    case sharpenLuminance
    case sixfoldReflectedTile
    case sixfoldRotatedTile
    case smoothLinearGradient
    case sobelGradients
    case spotColor
    case spotLight
    case starShineGenerator
    case straighten
    case stretchCrop
    case stripesGenerator
    case sunbeamsGenerator
    case swipeTransition
    case temperatureAndTint
    case textImageGenerator
    case thermal
    case toneCurve
    case toneMapHeadroom
    case torusLensDistortion
    case triangleKaleidoscope
    case triangleTile
    case twelvefoldReflectedTile
    case twirlDistortion
    case unsharpMask
    case vibrance
    case vignette
    case vignetteEffect
    case vividLightBlendMode
    case vortexDistortion
    case whitePointAdjust
    case zoomBlur
}

public extension CIFilterNodeKind {
    var impl: NodeImpl {
        switch self {
        case .accordionFoldTransition: return Nodes.CIAccordionFoldTransitionNode.impl()
        case .affineClamp: return Nodes.CIAffineClampNode.impl()
        case .affineTile: return Nodes.CIAffineTileNode.impl()
        case .areaAverage: return Nodes.CIAreaAverageNode.impl()
        case .areaBoundsRed: return Nodes.CIAreaBoundsRedNode.impl()
        case .areaHistogram: return Nodes.CIAreaHistogramNode.impl()
        case .areaLogarithmicHistogram: return Nodes.CIAreaLogarithmicHistogramNode.impl()
        case .areaMaximum: return Nodes.CIAreaMaximumNode.impl()
        case .areaMaximumAlpha: return Nodes.CIAreaMaximumAlphaNode.impl()
        case .areaMinMax: return Nodes.CIAreaMinMaxNode.impl()
        case .areaMinMaxRed: return Nodes.CIAreaMinMaxRedNode.impl()
        case .areaMinimum: return Nodes.CIAreaMinimumNode.impl()
        case .areaMinimumAlpha: return Nodes.CIAreaMinimumAlphaNode.impl()
        case .attributedTextImageGenerator: return Nodes.CIAttributedTextImageGeneratorNode.impl()
        case .barsSwipeTransition: return Nodes.CIBarsSwipeTransitionNode.impl()
        case .bicubicScaleTransform: return Nodes.CIBicubicScaleTransformNode.impl()
        case .blendWithRedMask: return Nodes.CIBlendWithMaskNode.impl()
        case .bloom: return Nodes.CIBloomNode.impl()
        case .blurredRectangleGenerator: return Nodes.CIBlurredRectangleGeneratorNode.impl()
        case .bokehBlur: return Nodes.CIBokehBlurNode.impl()
        case .boxBlur: return Nodes.CIBoxBlurNode.impl()
        case .bumpDistortion: return Nodes.CIBumpDistortionNode.impl()
        case .bumpDistortionLinear: return Nodes.CIBumpDistortionLinearNode.impl()
        case .cannyEdgeDetector: return Nodes.CICannyEdgeDetectorNode.impl()
        case .checkerboardGenerator: return Nodes.CICheckerboardGeneratorNode.impl()
        case .circleSplashDistortion: return Nodes.CICircleSplashDistortionNode.impl()
        case .circularScreen: return Nodes.CICircularScreenNode.impl()
        case .circularWrap: return Nodes.CICircularWrapNode.impl()
        case .cmykHalftone: return Nodes.CICMYKHalftoneNode.impl()
        case .code128BarcodeGenerator: return Nodes.CICode128BarcodeGeneratorNode.impl()
        case .colorAbsoluteDifference: return Nodes.CIColorAbsoluteDifferenceNode.impl()
        case .colorClamp: return Nodes.CIColorClampNode.impl()
        case .colorControls: return Nodes.CIColorControlsNode.impl()
        case .colorCrossPolynomial: return Nodes.CIColorCrossPolynomialNode.impl()
        case .colorCube: return Nodes.CIColorCubeNode.impl()
        case .colorCubeWithColorSpace: return Nodes.CIColorCubeWithColorSpaceNode.impl()
        case .colorCubesMixedWithMask: return Nodes.CIColorCubesMixedWithMaskNode.impl()
        case .colorCurves: return Nodes.CIColorCurvesNode.impl()
        case .colorInvert: return Nodes.CIColorInvertNode.impl()
        case .colorMap: return Nodes.CIColorMapNode.impl()
        case .colorMatrix: return Nodes.CIColorMatrixNode.impl()
        case .colorMonochrome: return Nodes.CIColorMonochromeNode.impl()
        case .colorPolynomial: return Nodes.CIColorPolynomialNode.impl()
        case .colorPosterize: return Nodes.CIColorPosterizeNode.impl()
        case .colorThreshold: return Nodes.CIColorThresholdNode.impl()
        case .colorThresholdOtsu: return Nodes.CIColorThresholdOtsuNode.impl()
        case .columnAverage: return Nodes.CIColumnAverageNode.impl()
        case .comicEffect: return Nodes.CIComicEffectNode.impl()
        case .convertRGBtoLab: return Nodes.CIConvertLabNode.impl()
        case .convolutionRGB9Vertical: return Nodes.CIConvolutionNode.impl()
        case .copyMachineTransition: return Nodes.CICopyMachineTransitionNode.impl()
        case .crystallize: return Nodes.CICrystallizeNode.impl()
        case .depthOfField: return Nodes.CIDepthOfFieldNode.impl()
        case .depthToDisparity: return Nodes.CIDepthToDisparityNode.impl()
        case .discBlur: return Nodes.CIDiscBlurNode.impl()
        case .disintegrateWithMaskTransition: return Nodes.CIDisintegrateWithMaskTransitionNode.impl()
        case .disparityToDepth: return Nodes.CIDisparityToDepthNode.impl()
        case .displacementDistortion: return Nodes.CIDisplacementDistortionNode.impl()
        case .dissolveTransition: return Nodes.CIDissolveTransitionNode.impl()
        case .dither: return Nodes.CIDitherNode.impl()
        case .documentEnhancer: return Nodes.CIDocumentEnhancerNode.impl()
        case .dotScreen: return Nodes.CIDotScreenNode.impl()
        case .droste: return Nodes.CIDrosteNode.impl()
        case .edgePreserveUpsample: return Nodes.CIEdgePreserveUpsampleNode.impl()
        case .edgeWork: return Nodes.CIEdgeWorkNode.impl()
        case .edges: return Nodes.CIEdgesNode.impl()
        case .eightfoldReflectedTile: return Nodes.CIEightfoldReflectedTileNode.impl()
        case .exposureAdjust: return Nodes.CIExposureAdjustNode.impl()
        case .falseColor: return Nodes.CIFalseColorNode.impl()
        case .flashTransition: return Nodes.CIFlashTransitionNode.impl()
        case .fourfoldReflectedTile: return Nodes.CIFourfoldReflectedTileNode.impl()
        case .fourfoldRotatedTile: return Nodes.CIFourfoldRotatedTileNode.impl()
        case .fourfoldTranslatedTile: return Nodes.CIFourfoldTranslatedTileNode.impl()
        case .gaborGradients: return Nodes.CIGaborGradientsNode.impl()
        case .gammaAdjust: return Nodes.CIGammaAdjustNode.impl()
        case .gaussianBlur: return Nodes.CIGaussianBlurNode.impl()
        case .gaussianGradient: return Nodes.CIGaussianGradientNode.impl()
        case .glassDistortion: return Nodes.CIGlassDistortionNode.impl()
        case .glassLozenge: return Nodes.CIGlassLozengeNode.impl()
        case .glideReflectedTile: return Nodes.CIGlideReflectedTileNode.impl()
        case .gloom: return Nodes.CIGloomNode.impl()
        case .hatchedScreen: return Nodes.CIHatchedScreenNode.impl()
        case .heightFieldFromMask: return Nodes.CIHeightFieldFromMaskNode.impl()
        case .hexagonalPixellate: return Nodes.CIHexagonalPixellateNode.impl()
        case .highlightShadowAdjust: return Nodes.CIHighlightShadowAdjustNode.impl()
        case .histogramDisplay: return Nodes.CIHistogramDisplayNode.impl()
        case .holeDistortion: return Nodes.CIHoleDistortionNode.impl()
        case .hueAdjust: return Nodes.CIHueAdjustNode.impl()
        case .hueSaturationValueGradient: return Nodes.CIHueSaturationValueGradientNode.impl()
        case .kMeans: return Nodes.CIKMeansNode.impl()
        case .kaleidoscope: return Nodes.CIKaleidoscopeNode.impl()
        case .keystoneCorrectionCombined: return Nodes.CIKeystoneCorrectionCombinedNode.impl()
        case .keystoneCorrectionHorizontal: return Nodes.CIKeystoneCorrectionHorizontalNode.impl()
        case .keystoneCorrectionVertical: return Nodes.CIKeystoneCorrectionVerticalNode.impl()
        case .labDeltaE: return Nodes.CILabDeltaENode.impl()
        case .lanczosScaleTransform: return Nodes.CILanczosScaleTransformNode.impl()
        case .lenticularHaloGenerator: return Nodes.CILenticularHaloGeneratorNode.impl()
        case .lightTunnel: return Nodes.CILightTunnelNode.impl()
        case .lineOverlay: return Nodes.CILineOverlayNode.impl()
        case .lineScreen: return Nodes.CILineScreenNode.impl()
        case .linearGradient: return Nodes.CILinearGradientNode.impl()
        case .linearToSRGBToneCurve: return Nodes.CILinearToSRGBToneCurveNode.impl()
        case .maskToAlpha: return Nodes.CIMaskToAlphaNode.impl()
        case .maskedVariableBlur: return Nodes.CIMaskedVariableBlurNode.impl()
        case .maximumComponent: return Nodes.CIMaximumComponentNode.impl()
        case .maximumScaleTransform: return Nodes.CIMaximumScaleTransformNode.impl()
        case .median: return Nodes.CIMedianNode.impl()
        case .minimumComponent: return Nodes.CIMinimumComponentNode.impl()
        case .mix: return Nodes.CIMixNode.impl()
        case .modTransition: return Nodes.CIModTransitionNode.impl()
        case .morphologyGradient: return Nodes.CIMorphologyGradientNode.impl()
        case .morphologyMaximum: return Nodes.CIMorphologyMaximumNode.impl()
        case .morphologyMinimum: return Nodes.CIMorphologyMinimumNode.impl()
        case .morphologyRectangleMaximum: return Nodes.CIMorphologyRectangleMaximumNode.impl()
        case .morphologyRectangleMinimum: return Nodes.CIMorphologyRectangleMinimumNode.impl()
        case .motionBlur: return Nodes.CIMotionBlurNode.impl()
        case .ninePartStretched: return Nodes.CINinePartStretchedNode.impl()
        case .ninePartTiled: return Nodes.CINinePartTiledNode.impl()
        case .noiseReduction: return Nodes.CINoiseReductionNode.impl()
        case .opTile: return Nodes.CIOpTileNode.impl()
        case .pageCurlTransition: return Nodes.CIPageCurlTransitionNode.impl()
        case .pageCurlWithShadowTransition: return Nodes.CIPageCurlWithShadowTransitionNode.impl()
        case .paletteCentroid: return Nodes.CIPaletteCentroidNode.impl()
        case .palettize: return Nodes.CIPalettizeNode.impl()
        case .parallelogramTile: return Nodes.CIParallelogramTileNode.impl()
        case .personSegmentation: return Nodes.CIPersonSegmentationNode.impl()
        case .perspectiveCorrection: return Nodes.CIPerspectiveCorrectionNode.impl()
        case .perspectiveRotate: return Nodes.CIPerspectiveRotateNode.impl()
        case .perspectiveTile: return Nodes.CIPerspectiveTileNode.impl()
        case .perspectiveTransform: return Nodes.CIPerspectiveTransformNode.impl()
        case .perspectiveTransformWithExtent: return Nodes.CIPerspectiveTransformWithExtentNode.impl()
        case .photoEffectTransfer: return Nodes.CIPhotoEffectNode.impl()
        case .pinchDistortion: return Nodes.CIPinchDistortionNode.impl()
        case .pixellate: return Nodes.CIPixellateNode.impl()
        case .pointillize: return Nodes.CIPointillizeNode.impl()
        case .qrCodeGenerator: return Nodes.CIQRCodeGeneratorNode.impl()
        case .radialGradient: return Nodes.CIRadialGradientNode.impl()
        case .randomGenerator: return Nodes.CIRandomGeneratorNode.impl()
        case .rippleTransition: return Nodes.CIRippleTransitionNode.impl()
        case .roundedRectangleGenerator: return Nodes.CIRoundedRectangleGeneratorNode.impl()
        case .roundedRectangleStrokeGenerator: return Nodes.CIRoundedRectangleStrokeGeneratorNode.impl()
        case .rowAverage: return Nodes.CIRowAverageNode.impl()
        case .sRGBToneCurveToLinear: return Nodes.CISRGBToneCurveToLinearNode.impl()
        case .saliencyMap: return Nodes.CISaliencyMapNode.impl()
        case .sepiaTone: return Nodes.CISepiaToneNode.impl()
        case .shadedMaterial: return Nodes.CIShadedMaterialNode.impl()
        case .sharpenLuminance: return Nodes.CISharpenLuminanceNode.impl()
        case .sixfoldReflectedTile: return Nodes.CISixfoldReflectedTileNode.impl()
        case .sixfoldRotatedTile: return Nodes.CISixfoldRotatedTileNode.impl()
        case .smoothLinearGradient: return Nodes.CISmoothLinearGradientNode.impl()
        case .sobelGradients: return Nodes.CISobelGradientsNode.impl()
        case .spotColor: return Nodes.CISpotColorNode.impl()
        case .spotLight: return Nodes.CISpotLightNode.impl()
        case .starShineGenerator: return Nodes.CIStarShineGeneratorNode.impl()
        case .straighten: return Nodes.CIStraightenNode.impl()
        case .stretchCrop: return Nodes.CIStretchCropNode.impl()
        case .stripesGenerator: return Nodes.CIStripesGeneratorNode.impl()
        case .sunbeamsGenerator: return Nodes.CISunbeamsGeneratorNode.impl()
        case .swipeTransition: return Nodes.CISwipeTransitionNode.impl()
        case .temperatureAndTint: return Nodes.CITemperatureAndTintNode.impl()
        case .textImageGenerator: return Nodes.CITextImageGeneratorNode.impl()
        case .thermal: return Nodes.CIThermalNode.impl()
        case .toneCurve: return Nodes.CIToneCurveNode.impl()
        case .toneMapHeadroom: return Nodes.CIToneMapHeadroomNode.impl()
        case .torusLensDistortion: return Nodes.CITorusLensDistortionNode.impl()
        case .triangleKaleidoscope: return Nodes.CITriangleKaleidoscopeNode.impl()
        case .triangleTile: return Nodes.CITriangleTileNode.impl()
        case .twelvefoldReflectedTile: return Nodes.CITwelvefoldReflectedTileNode.impl()
        case .twirlDistortion: return Nodes.CITwirlDistortionNode.impl()
        case .unsharpMask: return Nodes.CIUnsharpMaskNode.impl()
        case .vibrance: return Nodes.CIVibranceNode.impl()
        case .vignette: return Nodes.CIVignetteNode.impl()
        case .vignetteEffect: return Nodes.CIVignetteEffectNode.impl()
        case .vividLightBlendMode: return Nodes.CICompositeOperationNode.impl()
        case .vortexDistortion: return Nodes.CIVortexDistortionNode.impl()
        case .whitePointAdjust: return Nodes.CIWhitePointAdjustNode.impl()
        case .zoomBlur: return Nodes.CIZoomBlurNode.impl()
        }
    }
}

public extension Nodes {
    struct CIAccordionFoldTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAccordionFoldTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                    .init(name: "bottomHeight", defaultValue: .float(0.0)),
                    .init(name: "numberOfFolds", defaultValue: .float(3.0)),
                    .init(name: "foldShadowAmount", defaultValue: .float(0.10000000149011612)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.accordionFoldTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.bottomHeight = Float(node.inputs[3].float)
                filter.numberOfFolds = Float(node.inputs[4].float)
                filter.foldShadowAmount = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAffineClampNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAffineClamp",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(
                        name: "transform",
                        defaultValue: .affineTransform(
                            AffineTransform(m11: 0.4, m12: 0.0, m21: 0.0, m22: 0.4, tX: 0.0, tY: 0.0)
                        )
                    ),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.affineClamp()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.transform = node.inputs[1].affineTransform.cgAffineTransform
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAffineTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAffineTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(
                        name: "transform",
                        defaultValue: .affineTransform(
                            AffineTransform(m11: 0.4, m12: 0.0, m21: 0.0, m22: 0.4, tX: 0.0, tY: 0.0)
                        )
                    ),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.affineTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.transform = node.inputs[1].affineTransform.cgAffineTransform
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaAverageNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaAverage",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaAverage()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaBoundsRedNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaBoundsRed",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaBoundsRed()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaHistogramNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaHistogram",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                    .init(name: "scale", defaultValue: .float(1.0)), .init(name: "count", defaultValue: .int(64)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaHistogram()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                filter.scale = Float(node.inputs[2].float)
                filter.count = node.inputs[3].int
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaLogarithmicHistogramNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaLogarithmicHistogram",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                    .init(name: "scale", defaultValue: .float(1.0)), .init(name: "count", defaultValue: .int(64)),
                    .init(name: "minimumStop", defaultValue: .float(-10.0)),
                    .init(name: "maximumStop", defaultValue: .float(4.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaLogarithmicHistogram()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                filter.scale = Float(node.inputs[2].float)
                filter.count = node.inputs[3].int
                filter.minimumStop = Float(node.inputs[4].float)
                filter.maximumStop = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaMaximumNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaMaximum",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaMaximum()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaMaximumAlphaNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaMaximumAlpha",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaMaximumAlpha()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaMinMaxNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaMinMax",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaMinMax()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaMinMaxRedNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaMinMaxRed",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaMinMaxRed()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaMinimumNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaMinimum",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaMinimum()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAreaMinimumAlphaNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAreaMinimumAlpha",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.areaMinimumAlpha()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIAttributedTextImageGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIAttributedTextImageGenerator",
                inputs: [
                    .init(name: "text", type: .attributedString), .init(name: "scaleFactor", defaultValue: .float(1.0)),
                    .init(name: "padding", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.attributedTextImageGenerator()
                filter.text = NSAttributedString(node.inputs[0].attributedString)
                filter.scaleFactor = Float(node.inputs[1].float)
                filter.padding = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBarsSwipeTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBarsSwipeTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                    .init(name: "angle", defaultValue: .float(3.1415927410125732)),
                    .init(name: "width", defaultValue: .float(30.0)),
                    .init(name: "barOffset", defaultValue: .float(10.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.barsSwipeTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                filter.width = Float(node.inputs[4].float)
                filter.barOffset = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBicubicScaleTransformNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBicubicScaleTransform",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "scale", defaultValue: .float(1.0)),
                    .init(name: "aspectRatio", defaultValue: .float(1.0)), .init(name: "parameterB", type: .float),
                    .init(name: "parameterC", type: .float),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.bicubicScaleTransform()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.scale = Float(node.inputs[1].float)
                filter.aspectRatio = Float(node.inputs[2].float)
                filter.parameterB = Float(node.inputs[3].float)
                filter.parameterC = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBlendWithMaskNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBlendWithMask",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "backgroundImage", type: .image),
                    .init(name: "maskImage", type: .image),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.blendWithRedMask()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.backgroundImage = await context.getImage(node.inputs[1].image)
                filter.maskImage = await context.getImage(node.inputs[2].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBloomNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBloom",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(10.0)),
                    .init(name: "intensity", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.bloom()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.intensity = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBlurredRectangleGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBlurredRectangleGenerator",
                inputs: [
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))),
                    .init(name: "sigma", defaultValue: .float(10.0)),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.blurredRectangleGenerator()
                filter.extent = node.inputs[0].rect
                filter.sigma = Float(node.inputs[1].float)
                filter.color = node.inputs[2].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBokehBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBokehBlur",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(20.0)),
                    .init(name: "ringAmount", defaultValue: .float(0.0)),
                    .init(name: "ringSize", defaultValue: .float(0.10000000149011612)),
                    .init(name: "softness", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.bokehBlur()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.ringAmount = Float(node.inputs[2].float)
                filter.ringSize = Float(node.inputs[3].float)
                filter.softness = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBoxBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBoxBlur",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(10.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.boxBlur()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIBumpDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBumpDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(300.0)), .init(name: "scale", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.bumpDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.scale = Float(node.inputs[3].float)
                if filter.inputImage != nil {
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
                }
            }

        }
    }
}
public extension Nodes {
    struct CIBumpDistortionLinearNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIBumpDistortionLinear",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(300.0)), .init(name: "angle", defaultValue: .float(0.0)),
                    .init(name: "scale", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.bumpDistortionLinear()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                filter.scale = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICannyEdgeDetectorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICannyEdgeDetector",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "gaussianSigma", defaultValue: .float(1.600000023841858)),
                    .init(name: "perceptual", defaultValue: .bool(false)),
                    .init(name: "thresholdHigh", defaultValue: .float(0.05000000074505806)),
                    .init(name: "thresholdLow", defaultValue: .float(0.019999999552965164)),
                    .init(name: "hysteresisPasses", defaultValue: .int(1)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.cannyEdgeDetector()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.gaussianSigma = Float(node.inputs[1].float)
                filter.perceptual = node.inputs[2].bool
                filter.thresholdHigh = Float(node.inputs[3].float)
                filter.thresholdLow = Float(node.inputs[4].float)
                filter.hysteresisPasses = node.inputs[5].int
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICheckerboardGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICheckerboardGenerator",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))),
                    .init(name: "width", defaultValue: .float(80.0)),
                    .init(name: "sharpness", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.checkerboardGenerator()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.color0 = node.inputs[1].color4.ciColor
                filter.color1 = node.inputs[2].color4.ciColor
                filter.width = Float(node.inputs[3].float)
                filter.sharpness = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICircleSplashDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICircleSplashDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(150.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.circleSplashDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICircularScreenNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICircularScreen",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "width", defaultValue: .float(6.0)),
                    .init(name: "sharpness", defaultValue: .float(0.699999988079071)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.circularScreen()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.width = Float(node.inputs[2].float)
                filter.sharpness = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICircularWrapNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICircularWrap",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(150.0)), .init(name: "angle", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.circularWrap()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICMYKHalftoneNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICMYKHalftone",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "width", defaultValue: .float(6.0)), .init(name: "angle", defaultValue: .float(0.0)),
                    .init(name: "sharpness", defaultValue: .float(0.699999988079071)),
                    .init(name: "grayComponentReplacement", type: .float),
                    .init(name: "underColorRemoval", type: .float),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.cmykHalftone()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.width = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                filter.sharpness = Float(node.inputs[4].float)
                filter.grayComponentReplacement = Float(node.inputs[5].float)
                filter.underColorRemoval = Float(node.inputs[6].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICode128BarcodeGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICode128BarcodeGenerator",
                inputs: [
                    .init(name: "message", type: .data), .init(name: "quietSpace", defaultValue: .float(10.0)),
                    .init(name: "barcodeHeight", defaultValue: .float(32.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.code128BarcodeGenerator()
                filter.message = node.inputs[0].data
                filter.quietSpace = Float(node.inputs[1].float)
                filter.barcodeHeight = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorAbsoluteDifferenceNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorAbsoluteDifference",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "inputImage2", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorAbsoluteDifference()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.inputImage2 = await context.getImage(node.inputs[1].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorClampNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorClamp",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "minComponents", defaultValue: .vector4(Vector4(x: 0.0, y: 0.0, z: 0.0, w: 0.0))),
                    .init(name: "maxComponents", defaultValue: .vector4(Vector4(x: 1.0, y: 1.0, z: 1.0, w: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorClamp()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.minComponents = node.inputs[1].vector4.ciVector
                filter.maxComponents = node.inputs[2].vector4.ciVector
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorControlsNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorControls",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "saturation", defaultValue: .float(1.0)),
                    .init(name: "brightness", defaultValue: .float(0.0)),
                    .init(name: "contrast", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorControls()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.saturation = Float(node.inputs[1].float)
                filter.brightness = Float(node.inputs[2].float)
                filter.contrast = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorCrossPolynomialNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorCrossPolynomial",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "redCoefficients", defaultValue: .vector4(Vector4(x: 1.0, y: 0.0, z: 0.0, w: 0.0))),
                    .init(name: "greenCoefficients", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                    .init(name: "blueCoefficients", defaultValue: .vector4(Vector4(x: 0.0, y: 0.0, z: 1.0, w: 0.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorCrossPolynomial()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.redCoefficients = node.inputs[1].vector4.ciVector
                filter.greenCoefficients = node.inputs[2].vector4.ciVector
                filter.blueCoefficients = node.inputs[3].vector4.ciVector
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorCubeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorCube",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "cubeDimension", defaultValue: .float(2.0)),
                    .init(
                        name: "cubeData",
                        defaultValue: .data(
                            Data(
                                base64Encoded:
                                    #"AAAAAAAAAAAAAAAAAACAPwAAgD8AAAAAAAAAAAAAgD8AAAAAAACAPwAAAAAAAIA/AACAPwAAgD8AAAAAAACAPwAAAAAAAAAAAACAPwAAgD8AAIA/AAAAAAAAgD8AAIA/AAAAAAAAgD8AAIA/AACAPwAAgD8AAIA/AACAPwAAgD8="#
                            )!
                        )
                    ), .init(name: "extrapolate", defaultValue: .bool(false)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorCube()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.cubeDimension = Float(node.inputs[1].float)
                filter.cubeData = node.inputs[2].data
                filter.extrapolate = node.inputs[3].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorCubeWithColorSpaceNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorCubeWithColorSpace",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "cubeDimension", defaultValue: .float(2.0)),
                    .init(
                        name: "cubeData",
                        defaultValue: .data(
                            Data(
                                base64Encoded:
                                    #"AAAAAAAAAAAAAAAAAACAPwAAgD8AAAAAAAAAAAAAgD8AAAAAAACAPwAAAAAAAIA/AACAPwAAgD8AAAAAAACAPwAAAAAAAAAAAACAPwAAgD8AAIA/AAAAAAAAgD8AAIA/AAAAAAAAgD8AAIA/AACAPwAAgD8AAIA/AACAPwAAgD8="#
                            )!
                        )
                    ), .init(name: "colorSpace", type: .colorSpace), .init(name: "extrapolate", type: .bool),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorCubeWithColorSpace()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.cubeDimension = Float(node.inputs[1].float)
                filter.cubeData = node.inputs[2].data
                filter.colorSpace = node.inputs[3].colorSpace.cgColorSpace()
                filter.extrapolate = node.inputs[4].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorCubesMixedWithMaskNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorCubesMixedWithMask",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "maskImage", type: .image),
                    .init(name: "cubeDimension", defaultValue: .float(2.0)),
                    .init(
                        name: "cube0Data",
                        defaultValue: .data(
                            Data(
                                base64Encoded:
                                    #"AAAAAAAAAAAAAAAAAACAPwAAgD8AAAAAAAAAAAAAgD8AAAAAAACAPwAAAAAAAIA/AACAPwAAgD8AAAAAAACAPwAAAAAAAAAAAACAPwAAgD8AAIA/AAAAAAAAgD8AAIA/AAAAAAAAgD8AAIA/AACAPwAAgD8AAIA/AACAPwAAgD8="#
                            )!
                        )
                    ),
                    .init(
                        name: "cube1Data",
                        defaultValue: .data(
                            Data(
                                base64Encoded:
                                    #"AAAAAAAAAAAAAAAAAACAPwAAgD8AAAAAAAAAAAAAgD8AAAAAAACAPwAAAAAAAIA/AACAPwAAgD8AAAAAAACAPwAAAAAAAAAAAACAPwAAgD8AAIA/AAAAAAAAgD8AAIA/AAAAAAAAgD8AAIA/AACAPwAAgD8AAIA/AACAPwAAgD8="#
                            )!
                        )
                    ), .init(name: "colorSpace", type: .colorSpace),
                    .init(name: "extrapolate", defaultValue: .bool(false)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorCubesMixedWithMask()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.maskImage = await context.getImage(node.inputs[1].image)
                filter.cubeDimension = Float(node.inputs[2].float)
                filter.cube0Data = node.inputs[3].data
                filter.cube1Data = node.inputs[4].data
                filter.colorSpace = node.inputs[5].colorSpace.cgColorSpace()
                filter.extrapolate = node.inputs[6].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorCurvesNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorCurves",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(
                        name: "curvesData",
                        defaultValue: .data(Data(base64Encoded: #"AAAAAAAAAAAAAAAAAAAAPwAAAD8AAAA/AACAPwAAgD8AAIA/"#)!)
                    ), .init(name: "curvesDomain", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                    .init(name: "colorSpace", type: .colorSpace),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorCurves()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.curvesData = node.inputs[1].data
                filter.curvesDomain = node.inputs[2].vector4.ciVector
                filter.colorSpace = node.inputs[3].colorSpace.cgColorSpace()
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorInvertNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorInvert",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorInvert()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorMapNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorMap",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "gradientImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorMap()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.gradientImage = await context.getImage(node.inputs[1].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorMatrixNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorMatrix",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "rVector", defaultValue: .vector4(Vector4(x: 1.0, y: 0.0, z: 0.0, w: 0.0))),
                    .init(name: "gVector", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                    .init(name: "bVector", defaultValue: .vector4(Vector4(x: 0.0, y: 0.0, z: 1.0, w: 0.0))),
                    .init(name: "aVector", defaultValue: .vector4(Vector4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))),
                    .init(name: "biasVector", defaultValue: .vector4(Vector4(x: 0.0, y: 0.0, z: 0.0, w: 0.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorMatrix()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.rVector = node.inputs[1].vector4.ciVector
                filter.gVector = node.inputs[2].vector4.ciVector
                filter.bVector = node.inputs[3].vector4.ciVector
                filter.aVector = node.inputs[4].vector4.ciVector
                filter.biasVector = node.inputs[5].vector4.ciVector
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorMonochromeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorMonochrome",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "color", defaultValue: .color4(Color4(red: 0.6, green: 0.45, blue: 0.3, alpha: 1.0))),
                    .init(name: "intensity", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorMonochrome()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.color = node.inputs[1].color4.ciColor
                filter.intensity = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorPolynomialNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorPolynomial",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "redCoefficients", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                    .init(name: "greenCoefficients", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                    .init(name: "blueCoefficients", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                    .init(name: "alphaCoefficients", defaultValue: .vector4(Vector4(x: 0.0, y: 1.0, z: 0.0, w: 0.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorPolynomial()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.redCoefficients = node.inputs[1].vector4.ciVector
                filter.greenCoefficients = node.inputs[2].vector4.ciVector
                filter.blueCoefficients = node.inputs[3].vector4.ciVector
                filter.alphaCoefficients = node.inputs[4].vector4.ciVector
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorPosterizeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorPosterize",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "levels", defaultValue: .float(6.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorPosterize()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.levels = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorThresholdNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorThreshold",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "threshold", defaultValue: .float(0.5))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorThreshold()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.threshold = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColorThresholdOtsuNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColorThresholdOtsu",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.colorThresholdOtsu()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIColumnAverageNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIColumnAverage",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.columnAverage()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIComicEffectNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIComicEffect",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.comicEffect()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIConvertLabNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIConvertLab",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "normalize", type: .bool)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.convertRGBtoLab()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.normalize = node.inputs[1].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIConvolutionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIConvolution",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "weights", type: .vector4),
                    .init(name: "bias", type: .float),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.convolutionRGB9Vertical()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.weights = node.inputs[1].vector4.ciVector
                filter.bias = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICopyMachineTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICopyMachineTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))),
                    .init(name: "color", defaultValue: .color4(Color4(red: 0.6, green: 1.0, blue: 0.8, alpha: 1.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(200.0)),
                    .init(name: "opacity", defaultValue: .float(1.2999999523162842)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.copyMachineTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.extent = node.inputs[3].rect
                filter.color = node.inputs[4].color4.ciColor
                filter.angle = Float(node.inputs[5].float)
                filter.width = Float(node.inputs[6].float)
                filter.opacity = Float(node.inputs[7].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICrystallizeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICrystallize",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(20.0)),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.crystallize()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.center = node.inputs[2].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDepthOfFieldNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDepthOfField",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "point0", defaultValue: .vector2(Vector2(x: 0.0, y: 300.0))),
                    .init(name: "point1", defaultValue: .vector2(Vector2(x: 300.0, y: 300.0))),
                    .init(name: "saturation", defaultValue: .float(1.5)),
                    .init(name: "unsharpMaskRadius", defaultValue: .float(2.5)),
                    .init(name: "unsharpMaskIntensity", defaultValue: .float(0.5)),
                    .init(name: "radius", defaultValue: .float(6.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.depthOfField()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.point0 = node.inputs[1].vector2.cgPoint
                filter.point1 = node.inputs[2].vector2.cgPoint
                filter.saturation = Float(node.inputs[3].float)
                filter.unsharpMaskRadius = Float(node.inputs[4].float)
                filter.unsharpMaskIntensity = Float(node.inputs[5].float)
                filter.radius = Float(node.inputs[6].float)
                if filter.inputImage != nil {
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
                }
            }

        }
    }
}
public extension Nodes {
    struct CIDepthToDisparityNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDepthToDisparity",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.depthToDisparity()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDiscBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDiscBlur",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(8.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.discBlur()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDisintegrateWithMaskTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDisintegrateWithMaskTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)), .init(name: "maskImage", type: .image),
                    .init(name: "shadowRadius", defaultValue: .float(8.0)),
                    .init(name: "shadowDensity", defaultValue: .float(0.6499999761581421)),
                    .init(name: "shadowOffset", defaultValue: .vector2(Vector2(x: 0.0, y: -10.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.disintegrateWithMaskTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.maskImage = await context.getImage(node.inputs[3].image)
                filter.shadowRadius = Float(node.inputs[4].float)
                filter.shadowDensity = Float(node.inputs[5].float)
                filter.shadowOffset = node.inputs[6].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDisparityToDepthNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDisparityToDepth",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.disparityToDepth()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDisplacementDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDisplacementDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "displacementImage", type: .image),
                    .init(name: "scale", defaultValue: .float(50.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.displacementDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.displacementImage = await context.getImage(node.inputs[1].image)
                filter.scale = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDissolveTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDissolveTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.dissolveTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDitherNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDither",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "intensity", defaultValue: .float(0.10000000149011612)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.dither()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.intensity = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDocumentEnhancerNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDocumentEnhancer",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "amount", defaultValue: .float(1.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.documentEnhancer()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.amount = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDotScreenNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDotScreen",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(6.0)),
                    .init(name: "sharpness", defaultValue: .float(0.699999988079071)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.dotScreen()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                filter.sharpness = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIDrosteNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIDroste",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "insetPoint0", defaultValue: .vector2(Vector2(x: 200.0, y: 200.0))),
                    .init(name: "insetPoint1", defaultValue: .vector2(Vector2(x: 400.0, y: 400.0))),
                    .init(name: "strands", defaultValue: .float(1.0)),
                    .init(name: "periodicity", defaultValue: .float(1.0)),
                    .init(name: "rotation", defaultValue: .float(0.0)), .init(name: "zoom", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.droste()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.insetPoint0 = node.inputs[1].vector2.cgPoint
                filter.insetPoint1 = node.inputs[2].vector2.cgPoint
                filter.strands = Float(node.inputs[3].float)
                filter.periodicity = Float(node.inputs[4].float)
                filter.rotation = Float(node.inputs[5].float)
                filter.zoom = Float(node.inputs[6].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIEdgePreserveUpsampleNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIEdgePreserveUpsample",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "smallImage", type: .image),
                    .init(name: "spatialSigma", type: .float), .init(name: "lumaSigma", type: .float),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.edgePreserveUpsample()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.smallImage = await context.getImage(node.inputs[1].image)
                filter.spatialSigma = Float(node.inputs[2].float)
                filter.lumaSigma = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIEdgeWorkNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIEdgeWork",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(3.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.edgeWork()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIEdgesNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIEdges",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "intensity", defaultValue: .float(1.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.edges()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.intensity = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIEightfoldReflectedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIEightfoldReflectedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.eightfoldReflectedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIExposureAdjustNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIExposureAdjust",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "ev", type: .float)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.exposureAdjust()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.ev = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIFalseColorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIFalseColor",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 0.3, green: 0.0, blue: 0.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.falseColor()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.color0 = node.inputs[1].color4.ciColor
                filter.color1 = node.inputs[2].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIFlashTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIFlashTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0))),
                    .init(name: "maxStriationRadius", defaultValue: .float(2.5799999237060547)),
                    .init(name: "striationStrength", defaultValue: .float(0.5)),
                    .init(name: "striationContrast", defaultValue: .float(1.375)),
                    .init(name: "fadeThreshold", defaultValue: .float(0.8500000238418579)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.flashTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.center = node.inputs[3].vector2.cgPoint
                filter.extent = node.inputs[4].rect
                filter.color = node.inputs[5].color4.ciColor
                filter.maxStriationRadius = Float(node.inputs[6].float)
                filter.striationStrength = Float(node.inputs[7].float)
                filter.striationContrast = Float(node.inputs[8].float)
                filter.fadeThreshold = Float(node.inputs[9].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIFourfoldReflectedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIFourfoldReflectedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                    .init(name: "acuteAngle", defaultValue: .float(1.5707963705062866)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.fourfoldReflectedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                filter.acuteAngle = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIFourfoldRotatedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIFourfoldRotatedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.fourfoldRotatedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIFourfoldTranslatedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIFourfoldTranslatedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                    .init(name: "acuteAngle", defaultValue: .float(1.5707963705062866)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.fourfoldTranslatedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                filter.acuteAngle = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGaborGradientsNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGaborGradients",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.gaborGradients()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGammaAdjustNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGammaAdjust",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "power", defaultValue: .float(1.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.gammaAdjust()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.power = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGaussianBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGaussianBlur",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(10.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.gaussianBlur()
                let inputImage = await context.getImage(node.inputs[0].image)
                filter.inputImage = inputImage?.clampedToExtent()
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(
                    await context.addImage(
                        filter.outputImage?.cropped(to: inputImage?.extent ?? .init()),
                        id: .nodeOutput(node.id, 0)
                    )
                )
            }

        }
    }
}
public extension Nodes {
    struct CIGaussianGradientNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGaussianGradient",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0))),
                    .init(name: "radius", defaultValue: .float(300.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.gaussianGradient()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.color0 = node.inputs[1].color4.ciColor
                filter.color1 = node.inputs[2].color4.ciColor
                filter.radius = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGlassDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGlassDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "textureImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "scale", defaultValue: .float(200.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.glassDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.textureImage = await context.getImage(node.inputs[1].image)
                filter.center = node.inputs[2].vector2.cgPoint
                filter.scale = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGlassLozengeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGlassLozenge",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "point0", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "point1", defaultValue: .vector2(Vector2(x: 350.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(100.0)),
                    .init(name: "refraction", defaultValue: .float(1.7000000476837158)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.glassLozenge()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.point0 = node.inputs[1].vector2.cgPoint
                filter.point1 = node.inputs[2].vector2.cgPoint
                filter.radius = Float(node.inputs[3].float)
                filter.refraction = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGlideReflectedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGlideReflectedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.glideReflectedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIGloomNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIGloom",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(10.0)),
                    .init(name: "intensity", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.gloom()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.intensity = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHatchedScreenNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHatchedScreen",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(6.0)),
                    .init(name: "sharpness", defaultValue: .float(0.699999988079071)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.hatchedScreen()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                filter.sharpness = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHeightFieldFromMaskNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHeightFieldFromMask",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(10.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.heightFieldFromMask()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHexagonalPixellateNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHexagonalPixellate",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "scale", defaultValue: .float(8.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.hexagonalPixellate()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.scale = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHighlightShadowAdjustNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHighlightShadowAdjust",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(0.0)),
                    .init(name: "shadowAmount", defaultValue: .float(0.0)),
                    .init(name: "highlightAmount", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.highlightShadowAdjust()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.shadowAmount = Float(node.inputs[2].float)
                filter.highlightAmount = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHistogramDisplayNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHistogramDisplay",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "height", type: .float),
                    .init(name: "highLimit", type: .float), .init(name: "lowLimit", type: .float),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.histogramDisplay()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.height = Float(node.inputs[1].float)
                filter.highLimit = Float(node.inputs[2].float)
                filter.lowLimit = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHoleDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHoleDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(150.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.holeDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHueAdjustNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHueAdjust",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "angle", defaultValue: .float(0.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.hueAdjust()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.angle = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIHueSaturationValueGradientNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIHueSaturationValueGradient",
                inputs: [
                    .init(name: "value", defaultValue: .float(1.0)), .init(name: "radius", defaultValue: .float(300.0)),
                    .init(name: "softness", defaultValue: .float(1.0)),
                    .init(name: "dither", defaultValue: .float(1.0)),
                    .init(
                        name: "colorSpace",
                        defaultValue: .colorSpace(ColorSpace(jsonString: #"{"named":{"_0":"kCGColorSpaceSRGB"}}"#)!)
                    ),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.hueSaturationValueGradient()
                filter.value = Float(node.inputs[0].float)
                filter.radius = Float(node.inputs[1].float)
                filter.softness = Float(node.inputs[2].float)
                filter.dither = Float(node.inputs[3].float)
                filter.colorSpace = node.inputs[4].colorSpace.cgColorSpace()
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIKMeansNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIKMeans",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                    .init(name: "inputMeans", type: .image), .init(name: "count", defaultValue: .int(8)),
                    .init(name: "passes", defaultValue: .float(5.0)),
                    .init(name: "perceptual", defaultValue: .bool(false)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.kMeans()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                filter.inputMeans = await context.getImage(node.inputs[2].image)
                filter.count = node.inputs[3].int
                filter.passes = Float(node.inputs[4].float)
                filter.perceptual = node.inputs[5].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIKaleidoscopeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIKaleidoscope",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "count", defaultValue: .int(6)),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.kaleidoscope()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.count = node.inputs[1].int
                filter.center = node.inputs[2].vector2.cgPoint
                filter.angle = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIKeystoneCorrectionCombinedNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIKeystoneCorrectionCombined",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "topLeft", type: .vector2),
                    .init(name: "topRight", type: .vector2), .init(name: "bottomRight", type: .vector2),
                    .init(name: "bottomLeft", type: .vector2), .init(name: "focalLength", defaultValue: .float(28.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.keystoneCorrectionCombined()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                filter.focalLength = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIKeystoneCorrectionHorizontalNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIKeystoneCorrectionHorizontal",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "topLeft", type: .vector2),
                    .init(name: "topRight", type: .vector2), .init(name: "bottomRight", type: .vector2),
                    .init(name: "bottomLeft", type: .vector2), .init(name: "focalLength", defaultValue: .float(28.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.keystoneCorrectionHorizontal()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                filter.focalLength = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIKeystoneCorrectionVerticalNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIKeystoneCorrectionVertical",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "topLeft", type: .vector2),
                    .init(name: "topRight", type: .vector2), .init(name: "bottomRight", type: .vector2),
                    .init(name: "bottomLeft", type: .vector2), .init(name: "focalLength", defaultValue: .float(28.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.keystoneCorrectionVertical()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                filter.focalLength = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILabDeltaENode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILabDeltaE",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "image2", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.labDeltaE()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.image2 = await context.getImage(node.inputs[1].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILanczosScaleTransformNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILanczosScaleTransform",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "scale", defaultValue: .float(1.0)),
                    .init(name: "aspectRatio", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.lanczosScaleTransform()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.scale = Float(node.inputs[1].float)
                filter.aspectRatio = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILenticularHaloGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILenticularHaloGenerator",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0))),
                    .init(name: "haloRadius", defaultValue: .float(70.0)),
                    .init(name: "haloWidth", defaultValue: .float(87.0)),
                    .init(name: "haloOverlap", defaultValue: .float(0.7699999809265137)),
                    .init(name: "striationStrength", defaultValue: .float(0.5)),
                    .init(name: "striationContrast", defaultValue: .float(1.0)),
                    .init(name: "time", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.lenticularHaloGenerator()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.color = node.inputs[1].color4.ciColor
                filter.haloRadius = Float(node.inputs[2].float)
                filter.haloWidth = Float(node.inputs[3].float)
                filter.haloOverlap = Float(node.inputs[4].float)
                filter.striationStrength = Float(node.inputs[5].float)
                filter.striationContrast = Float(node.inputs[6].float)
                filter.time = Float(node.inputs[7].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILightTunnelNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILightTunnel",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "rotation", defaultValue: .float(0.0)),
                    .init(name: "radius", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.lightTunnel()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.rotation = Float(node.inputs[2].float)
                filter.radius = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILineOverlayNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILineOverlay",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "nrNoiseLevel", type: .float),
                    .init(name: "nrSharpness", type: .float), .init(name: "edgeIntensity", defaultValue: .float(1.0)),
                    .init(name: "threshold", defaultValue: .float(0.10000000149011612)),
                    .init(name: "contrast", defaultValue: .float(50.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.lineOverlay()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.nrNoiseLevel = Float(node.inputs[1].float)
                filter.nrSharpness = Float(node.inputs[2].float)
                filter.edgeIntensity = Float(node.inputs[3].float)
                filter.threshold = Float(node.inputs[4].float)
                filter.contrast = Float(node.inputs[5].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILineScreenNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILineScreen",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(6.0)),
                    .init(name: "sharpness", defaultValue: .float(0.699999988079071)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.lineScreen()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                filter.sharpness = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILinearGradientNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILinearGradient",
                inputs: [
                    .init(name: "point0", defaultValue: .vector2(Vector2(x: 0.0, y: 0.0))),
                    .init(name: "point1", defaultValue: .vector2(Vector2(x: 200.0, y: 200.0))),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.linearGradient()
                filter.point0 = node.inputs[0].vector2.cgPoint
                filter.point1 = node.inputs[1].vector2.cgPoint
                filter.color0 = node.inputs[2].color4.ciColor
                filter.color1 = node.inputs[3].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CILinearToSRGBToneCurveNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CILinearToSRGBToneCurve",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.linearToSRGBToneCurve()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMaskToAlphaNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMaskToAlpha",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.maskToAlpha()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMaskedVariableBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMaskedVariableBlur",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "mask", type: .image),
                    .init(name: "radius", defaultValue: .float(5.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.maskedVariableBlur()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.mask = await context.getImage(node.inputs[1].image)
                filter.radius = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMaximumComponentNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMaximumComponent",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.maximumComponent()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMaximumScaleTransformNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMaximumScaleTransform",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "scale", defaultValue: .float(1.0)),
                    .init(name: "aspectRatio", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.maximumScaleTransform()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.scale = Float(node.inputs[1].float)
                filter.aspectRatio = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMedianNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMedian",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.median()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMinimumComponentNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMinimumComponent",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.minimumComponent()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMixNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMix",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "backgroundImage", type: .image),
                    .init(name: "amount", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.mix()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.backgroundImage = await context.getImage(node.inputs[1].image)
                filter.amount = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIModTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIModTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(2.0)), .init(name: "radius", defaultValue: .float(150.0)),
                    .init(name: "compression", defaultValue: .float(300.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.modTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.center = node.inputs[3].vector2.cgPoint
                filter.angle = Float(node.inputs[4].float)
                filter.radius = Float(node.inputs[5].float)
                filter.compression = Float(node.inputs[6].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMorphologyGradientNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMorphologyGradient",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(5.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.morphologyGradient()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMorphologyMaximumNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMorphologyMaximum",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(0.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.morphologyMaximum()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMorphologyMinimumNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMorphologyMinimum",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(0.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.morphologyMinimum()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMorphologyRectangleMaximumNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMorphologyRectangleMaximum",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "width", defaultValue: .float(5.0)),
                    .init(name: "height", defaultValue: .float(5.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.morphologyRectangleMaximum()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.width = Float(node.inputs[1].float)
                filter.height = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMorphologyRectangleMinimumNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMorphologyRectangleMinimum",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "width", defaultValue: .float(5.0)),
                    .init(name: "height", defaultValue: .float(5.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.morphologyRectangleMinimum()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.width = Float(node.inputs[1].float)
                filter.height = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIMotionBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIMotionBlur",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(20.0)),
                    .init(name: "angle", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.motionBlur()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.angle = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CINinePartStretchedNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CINinePartStretched",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "breakpoint0", defaultValue: .vector2(Vector2(x: 50.0, y: 50.0))),
                    .init(name: "breakpoint1", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "growAmount", defaultValue: .vector2(Vector2(x: 100.0, y: 100.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.ninePartStretched()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.breakpoint0 = node.inputs[1].vector2.cgPoint
                filter.breakpoint1 = node.inputs[2].vector2.cgPoint
                filter.growAmount = node.inputs[3].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CINinePartTiledNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CINinePartTiled",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "breakpoint0", defaultValue: .vector2(Vector2(x: 50.0, y: 50.0))),
                    .init(name: "breakpoint1", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "growAmount", defaultValue: .vector2(Vector2(x: 100.0, y: 100.0))),
                    .init(name: "flipYTiles", defaultValue: .bool(true)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.ninePartTiled()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.breakpoint0 = node.inputs[1].vector2.cgPoint
                filter.breakpoint1 = node.inputs[2].vector2.cgPoint
                filter.growAmount = node.inputs[3].vector2.cgPoint
                filter.flipYTiles = node.inputs[4].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CINoiseReductionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CINoiseReduction",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "noiseLevel", defaultValue: .float(0.019999999552965164)),
                    .init(name: "sharpness", defaultValue: .float(0.4000000059604645)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.noiseReduction()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.noiseLevel = Float(node.inputs[1].float)
                filter.sharpness = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIOpTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIOpTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "scale", defaultValue: .float(2.799999952316284)),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(65.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.opTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.scale = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                filter.width = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPageCurlTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPageCurlTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)), .init(name: "backsideImage", type: .image),
                    .init(name: "shadingImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "radius", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.pageCurlTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.backsideImage = await context.getImage(node.inputs[3].image)
                filter.shadingImage = await context.getImage(node.inputs[4].image)
                filter.extent = node.inputs[5].rect
                filter.angle = Float(node.inputs[6].float)
                filter.radius = Float(node.inputs[7].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPageCurlWithShadowTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPageCurlWithShadowTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)), .init(name: "backsideImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "radius", defaultValue: .float(100.0)),
                    .init(name: "shadowSize", defaultValue: .float(0.5)),
                    .init(name: "shadowAmount", defaultValue: .float(0.699999988079071)),
                    .init(name: "shadowExtent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.pageCurlWithShadowTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.backsideImage = await context.getImage(node.inputs[3].image)
                filter.extent = node.inputs[4].rect
                filter.angle = Float(node.inputs[5].float)
                filter.radius = Float(node.inputs[6].float)
                filter.shadowSize = Float(node.inputs[7].float)
                filter.shadowAmount = Float(node.inputs[8].float)
                filter.shadowExtent = node.inputs[9].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPaletteCentroidNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPaletteCentroid",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "paletteImage", type: .image),
                    .init(name: "perceptual", defaultValue: .bool(false)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.paletteCentroid()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.paletteImage = await context.getImage(node.inputs[1].image)
                filter.perceptual = node.inputs[2].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPalettizeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPalettize",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "paletteImage", type: .image),
                    .init(name: "perceptual", defaultValue: .bool(false)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.palettize()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.paletteImage = await context.getImage(node.inputs[1].image)
                filter.perceptual = node.inputs[2].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIParallelogramTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIParallelogramTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)),
                    .init(name: "acuteAngle", defaultValue: .float(1.5707963705062866)),
                    .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.parallelogramTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.acuteAngle = Float(node.inputs[3].float)
                filter.width = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPersonSegmentationNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPersonSegmentation",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "qualityLevel", defaultValue: .int(0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.personSegmentation()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.qualityLevel = node.inputs[1].int
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPerspectiveCorrectionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPerspectiveCorrection",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "topLeft", defaultValue: .vector2(Vector2(x: 118.0, y: 484.0))),
                    .init(name: "topRight", defaultValue: .vector2(Vector2(x: 646.0, y: 507.0))),
                    .init(name: "bottomRight", defaultValue: .vector2(Vector2(x: 548.0, y: 140.0))),
                    .init(name: "bottomLeft", defaultValue: .vector2(Vector2(x: 155.0, y: 153.0))),
                    .init(name: "crop", defaultValue: .bool(true)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.perspectiveCorrection()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                filter.crop = node.inputs[5].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPerspectiveRotateNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPerspectiveRotate",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "focalLength", defaultValue: .float(28.0)),
                    .init(name: "pitch", defaultValue: .float(0.0)), .init(name: "yaw", defaultValue: .float(0.0)),
                    .init(name: "roll", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.perspectiveRotate()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.focalLength = Float(node.inputs[1].float)
                filter.pitch = Float(node.inputs[2].float)
                filter.yaw = Float(node.inputs[3].float)
                filter.roll = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPerspectiveTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPerspectiveTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "topLeft", defaultValue: .vector2(Vector2(x: 118.0, y: 484.0))),
                    .init(name: "topRight", defaultValue: .vector2(Vector2(x: 646.0, y: 507.0))),
                    .init(name: "bottomRight", defaultValue: .vector2(Vector2(x: 548.0, y: 140.0))),
                    .init(name: "bottomLeft", defaultValue: .vector2(Vector2(x: 155.0, y: 153.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.perspectiveTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPerspectiveTransformNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPerspectiveTransform",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "topLeft", defaultValue: .vector2(Vector2(x: 118.0, y: 484.0))),
                    .init(name: "topRight", defaultValue: .vector2(Vector2(x: 646.0, y: 507.0))),
                    .init(name: "bottomRight", defaultValue: .vector2(Vector2(x: 548.0, y: 140.0))),
                    .init(name: "bottomLeft", defaultValue: .vector2(Vector2(x: 155.0, y: 153.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.perspectiveTransform()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPerspectiveTransformWithExtentNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPerspectiveTransformWithExtent",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "topLeft", defaultValue: .vector2(Vector2(x: 118.0, y: 484.0))),
                    .init(name: "topRight", defaultValue: .vector2(Vector2(x: 646.0, y: 507.0))),
                    .init(name: "bottomRight", defaultValue: .vector2(Vector2(x: 548.0, y: 140.0))),
                    .init(name: "bottomLeft", defaultValue: .vector2(Vector2(x: 155.0, y: 153.0))),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.perspectiveTransformWithExtent()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.topLeft = node.inputs[1].vector2.cgPoint
                filter.topRight = node.inputs[2].vector2.cgPoint
                filter.bottomRight = node.inputs[3].vector2.cgPoint
                filter.bottomLeft = node.inputs[4].vector2.cgPoint
                filter.extent = node.inputs[5].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPhotoEffectNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPhotoEffect",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "extrapolate", defaultValue: .bool(false)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.photoEffectTransfer()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extrapolate = node.inputs[1].bool
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPinchDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPinchDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(300.0)), .init(name: "scale", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.pinchDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.scale = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPixellateNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPixellate",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "scale", defaultValue: .float(8.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.pixellate()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.scale = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIPointillizeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIPointillize",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(20.0)),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.pointillize()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.center = node.inputs[2].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIQRCodeGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIQRCodeGenerator",
                inputs: [
                    .init(name: "message", type: .data), .init(name: "correctionLevel", defaultValue: .string("M")),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.qrCodeGenerator()
                filter.message = node.inputs[0].data
                filter.correctionLevel = node.inputs[1].string
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIRadialGradientNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIRadialGradient",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius0", defaultValue: .float(5.0)),
                    .init(name: "radius1", defaultValue: .float(100.0)),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.radialGradient()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.radius0 = Float(node.inputs[1].float)
                filter.radius1 = Float(node.inputs[2].float)
                filter.color0 = node.inputs[3].color4.ciColor
                filter.color1 = node.inputs[4].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIRandomGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIRandomGenerator",
                inputs: [],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.randomGenerator()

                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIRippleTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIRippleTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)), .init(name: "shadingImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))),
                    .init(name: "width", defaultValue: .float(100.0)), .init(name: "scale", defaultValue: .float(50.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.rippleTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.shadingImage = await context.getImage(node.inputs[3].image)
                filter.center = node.inputs[4].vector2.cgPoint
                filter.extent = node.inputs[5].rect
                filter.width = Float(node.inputs[6].float)
                filter.scale = Float(node.inputs[7].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIRoundedRectangleGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIRoundedRectangleGenerator",
                inputs: [
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))),
                    .init(name: "radius", defaultValue: .float(10.0)),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.roundedRectangleGenerator()
                filter.extent = node.inputs[0].rect
                filter.radius = Float(node.inputs[1].float)
                filter.color = node.inputs[2].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIRoundedRectangleStrokeGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIRoundedRectangleStrokeGenerator",
                inputs: [
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))),
                    .init(name: "radius", defaultValue: .float(10.0)), .init(name: "width", defaultValue: .float(10.0)),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.roundedRectangleStrokeGenerator()
                filter.extent = node.inputs[0].rect
                filter.radius = Float(node.inputs[1].float)
                filter.width = Float(node.inputs[2].float)
                filter.color = node.inputs[3].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIRowAverageNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIRowAverage",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 640.0, height: 80.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.rowAverage()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.extent = node.inputs[1].rect
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISRGBToneCurveToLinearNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISRGBToneCurveToLinear",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sRGBToneCurveToLinear()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISaliencyMapNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISaliencyMap",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.saliencyMap()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISepiaToneNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISepiaTone",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "intensity", defaultValue: .float(1.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sepiaTone()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.intensity = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIShadedMaterialNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIShadedMaterial",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "shadingImage", type: .image),
                    .init(name: "scale", defaultValue: .float(10.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.shadedMaterial()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.shadingImage = await context.getImage(node.inputs[1].image)
                filter.scale = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISharpenLuminanceNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISharpenLuminance",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "sharpness", defaultValue: .float(0.4000000059604645)),
                    .init(name: "radius", defaultValue: .float(1.690000057220459)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sharpenLuminance()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.sharpness = Float(node.inputs[1].float)
                filter.radius = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISixfoldReflectedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISixfoldReflectedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sixfoldReflectedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISixfoldRotatedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISixfoldRotatedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sixfoldRotatedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISmoothLinearGradientNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISmoothLinearGradient",
                inputs: [
                    .init(name: "point0", defaultValue: .vector2(Vector2(x: 0.0, y: 0.0))),
                    .init(name: "point1", defaultValue: .vector2(Vector2(x: 200.0, y: 200.0))),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.smoothLinearGradient()
                filter.point0 = node.inputs[0].vector2.cgPoint
                filter.point1 = node.inputs[1].vector2.cgPoint
                filter.color0 = node.inputs[2].color4.ciColor
                filter.color1 = node.inputs[3].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISobelGradientsNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISobelGradients",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sobelGradients()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISpotColorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISpotColor",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(
                        name: "centerColor1",
                        defaultValue: .color4(Color4(red: 0.0784, green: 0.0627, blue: 0.0706, alpha: 1.0))
                    ),
                    .init(
                        name: "replacementColor1",
                        defaultValue: .color4(Color4(red: 0.4392, green: 0.1922, blue: 0.1961, alpha: 1.0))
                    ), .init(name: "closeness1", defaultValue: .float(0.2199999988079071)),
                    .init(name: "contrast1", defaultValue: .float(0.9800000190734863)),
                    .init(
                        name: "centerColor2",
                        defaultValue: .color4(Color4(red: 0.5255, green: 0.3059, blue: 0.3451, alpha: 1.0))
                    ),
                    .init(
                        name: "replacementColor2",
                        defaultValue: .color4(Color4(red: 0.9137, green: 0.5608, blue: 0.5059, alpha: 1.0))
                    ), .init(name: "closeness2", defaultValue: .float(0.15000000596046448)),
                    .init(name: "contrast2", defaultValue: .float(0.9800000190734863)),
                    .init(
                        name: "centerColor3",
                        defaultValue: .color4(Color4(red: 0.9216, green: 0.4549, blue: 0.3333, alpha: 1.0))
                    ),
                    .init(
                        name: "replacementColor3",
                        defaultValue: .color4(Color4(red: 0.9098, green: 0.7529, blue: 0.6078, alpha: 1.0))
                    ), .init(name: "closeness3", defaultValue: .float(0.5)),
                    .init(name: "contrast3", defaultValue: .float(0.9900000095367432)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.spotColor()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.centerColor1 = node.inputs[1].color4.ciColor
                filter.replacementColor1 = node.inputs[2].color4.ciColor
                filter.closeness1 = Float(node.inputs[3].float)
                filter.contrast1 = Float(node.inputs[4].float)
                filter.centerColor2 = node.inputs[5].color4.ciColor
                filter.replacementColor2 = node.inputs[6].color4.ciColor
                filter.closeness2 = Float(node.inputs[7].float)
                filter.contrast2 = Float(node.inputs[8].float)
                filter.centerColor3 = node.inputs[9].color4.ciColor
                filter.replacementColor3 = node.inputs[10].color4.ciColor
                filter.closeness3 = Float(node.inputs[11].float)
                filter.contrast3 = Float(node.inputs[12].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISpotLightNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISpotLight",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "lightPosition", defaultValue: .vector3(Vector3(x: 400.0, y: 600.0, z: 150.0))),
                    .init(name: "lightPointsAt", defaultValue: .vector3(Vector3(x: 200.0, y: 200.0, z: 0.0))),
                    .init(name: "brightness", defaultValue: .float(3.0)),
                    .init(name: "concentration", defaultValue: .float(0.10000000149011612)),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.spotLight()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.lightPosition = node.inputs[1].vector3.ciVector
                filter.lightPointsAt = node.inputs[2].vector3.ciVector
                filter.brightness = Float(node.inputs[3].float)
                filter.concentration = Float(node.inputs[4].float)
                filter.color = node.inputs[5].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIStarShineGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIStarShineGenerator",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0))),
                    .init(name: "radius", defaultValue: .float(50.0)),
                    .init(name: "crossScale", defaultValue: .float(15.0)),
                    .init(name: "crossAngle", defaultValue: .float(0.6000000238418579)),
                    .init(name: "crossOpacity", defaultValue: .float(-2.0)),
                    .init(name: "crossWidth", defaultValue: .float(2.5)),
                    .init(name: "epsilon", defaultValue: .float(-2.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.starShineGenerator()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.color = node.inputs[1].color4.ciColor
                filter.radius = Float(node.inputs[2].float)
                filter.crossScale = Float(node.inputs[3].float)
                filter.crossAngle = Float(node.inputs[4].float)
                filter.crossOpacity = Float(node.inputs[5].float)
                filter.crossWidth = Float(node.inputs[6].float)
                filter.epsilon = Float(node.inputs[7].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIStraightenNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIStraighten",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "angle", type: .float)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.straighten()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.angle = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIStretchCropNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIStretchCrop",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "size", defaultValue: .vector2(Vector2(x: 1280.0, y: 720.0))),
                    .init(name: "cropAmount", defaultValue: .float(0.25)),
                    .init(name: "centerStretchAmount", defaultValue: .float(0.25)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.stretchCrop()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.size = node.inputs[1].vector2.cgPoint
                filter.cropAmount = Float(node.inputs[2].float)
                filter.centerStretchAmount = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIStripesGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIStripesGenerator",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "color0", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "color1", defaultValue: .color4(Color4(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))),
                    .init(name: "width", defaultValue: .float(80.0)),
                    .init(name: "sharpness", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.stripesGenerator()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.color0 = node.inputs[1].color4.ciColor
                filter.color1 = node.inputs[2].color4.ciColor
                filter.width = Float(node.inputs[3].float)
                filter.sharpness = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISunbeamsGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISunbeamsGenerator",
                inputs: [
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))),
                    .init(name: "sunRadius", defaultValue: .float(40.0)),
                    .init(name: "maxStriationRadius", defaultValue: .float(2.5799999237060547)),
                    .init(name: "striationStrength", defaultValue: .float(0.5)),
                    .init(name: "striationContrast", defaultValue: .float(1.375)),
                    .init(name: "time", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.sunbeamsGenerator()
                filter.center = node.inputs[0].vector2.cgPoint
                filter.color = node.inputs[1].color4.ciColor
                filter.sunRadius = Float(node.inputs[2].float)
                filter.maxStriationRadius = Float(node.inputs[3].float)
                filter.striationStrength = Float(node.inputs[4].float)
                filter.striationContrast = Float(node.inputs[5].float)
                filter.time = Float(node.inputs[6].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CISwipeTransitionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CISwipeTransition",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "targetImage", type: .image),
                    .init(name: "time", defaultValue: .float(0.0)),
                    .init(name: "extent", defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(300.0)),
                    .init(name: "opacity", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.swipeTransition()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.targetImage = await context.getImage(node.inputs[1].image)
                filter.time = Float(node.inputs[2].float)
                filter.extent = node.inputs[3].rect
                filter.color = node.inputs[4].color4.ciColor
                filter.angle = Float(node.inputs[5].float)
                filter.width = Float(node.inputs[6].float)
                filter.opacity = Float(node.inputs[7].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITemperatureAndTintNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITemperatureAndTint",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "neutral", defaultValue: .vector4(Vector4(x: 6500.0, y: 0.0, z: 0.0, w: 0.0))),
                    .init(name: "targetNeutral", defaultValue: .vector4(Vector4(x: 6500.0, y: 0.0, z: 0.0, w: 0.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.temperatureAndTint()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.neutral = node.inputs[1].vector2.ciVector
                filter.targetNeutral = node.inputs[2].vector2.ciVector
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITextImageGeneratorNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITextImageGenerator",
                inputs: [
                    .init(name: "text", type: .string), .init(name: "fontName", defaultValue: .string("HelveticaNeue")),
                    .init(name: "fontSize", defaultValue: .float(12.0)),
                    .init(name: "scaleFactor", defaultValue: .float(1.0)),
                    .init(name: "padding", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.textImageGenerator()
                filter.text = node.inputs[0].string
                filter.fontName = node.inputs[1].string
                filter.fontSize = Float(node.inputs[2].float)
                filter.scaleFactor = Float(node.inputs[3].float)
                filter.padding = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIThermalNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIThermal",
                inputs: [.init(name: "inputImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.thermal()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIToneCurveNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIToneCurve",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "point0", defaultValue: .vector2(Vector2(x: 0.0, y: 0.0))),
                    .init(name: "point1", defaultValue: .vector2(Vector2(x: 0.25, y: 0.25))),
                    .init(name: "point2", defaultValue: .vector2(Vector2(x: 0.5, y: 0.5))),
                    .init(name: "point3", defaultValue: .vector2(Vector2(x: 0.75, y: 0.75))),
                    .init(name: "point4", defaultValue: .vector2(Vector2(x: 1.0, y: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.toneCurve()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.point0 = node.inputs[1].vector2.cgPoint
                filter.point1 = node.inputs[2].vector2.cgPoint
                filter.point2 = node.inputs[3].vector2.cgPoint
                filter.point3 = node.inputs[4].vector2.cgPoint
                filter.point4 = node.inputs[5].vector2.cgPoint
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIToneMapHeadroomNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIToneMapHeadroom",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "sourceHeadroom", type: .float),
                    .init(name: "targetHeadroom", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.toneMapHeadroom()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.sourceHeadroom = Float(node.inputs[1].float)
                filter.targetHeadroom = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITorusLensDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITorusLensDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(160.0)),
                    .init(name: "width", defaultValue: .float(80.0)),
                    .init(name: "refraction", defaultValue: .float(1.7000000476837158)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.torusLensDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                filter.refraction = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITriangleKaleidoscopeNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITriangleKaleidoscope",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "point", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "size", defaultValue: .float(700.0)),
                    .init(name: "rotation", defaultValue: .float(5.924285411834717)),
                    .init(name: "decay", defaultValue: .float(0.8500000238418579)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.triangleKaleidoscope()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.point = node.inputs[1].vector2.cgPoint
                filter.size = Float(node.inputs[2].float)
                filter.rotation = Float(node.inputs[3].float)
                filter.decay = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITriangleTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITriangleTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.triangleTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITwelvefoldReflectedTileNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITwelvefoldReflectedTile",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "angle", defaultValue: .float(0.0)), .init(name: "width", defaultValue: .float(100.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.twelvefoldReflectedTile()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.angle = Float(node.inputs[2].float)
                filter.width = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CITwirlDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CITwirlDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(300.0)),
                    .init(name: "angle", defaultValue: .float(3.1415927410125732)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.twirlDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIUnsharpMaskNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIUnsharpMask",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "radius", defaultValue: .float(2.5)),
                    .init(name: "intensity", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.unsharpMask()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.radius = Float(node.inputs[1].float)
                filter.intensity = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIVibranceNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIVibrance",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "amount", defaultValue: .float(0.0))],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.vibrance()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.amount = Float(node.inputs[1].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIVignetteNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIVignette",
                inputs: [
                    .init(name: "inputImage", type: .image), .init(name: "intensity", defaultValue: .float(0.0)),
                    .init(name: "radius", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.vignette()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.intensity = Float(node.inputs[1].float)
                filter.radius = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIVignetteEffectNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIVignetteEffect",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(150.0)),
                    .init(name: "intensity", defaultValue: .float(1.0)),
                    .init(name: "falloff", defaultValue: .float(0.5)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.vignetteEffect()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.intensity = Float(node.inputs[3].float)
                filter.falloff = Float(node.inputs[4].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CICompositeOperationNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CICompositeOperation",
                inputs: [.init(name: "inputImage", type: .image), .init(name: "backgroundImage", type: .image)],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.vividLightBlendMode()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.backgroundImage = await context.getImage(node.inputs[1].image)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIVortexDistortionNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIVortexDistortion",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "radius", defaultValue: .float(300.0)),
                    .init(name: "angle", defaultValue: .float(56.548667907714844)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.vortexDistortion()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.radius = Float(node.inputs[2].float)
                filter.angle = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIWhitePointAdjustNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIWhitePointAdjust",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "color", defaultValue: .color4(Color4(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.whitePointAdjust()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.color = node.inputs[1].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
public extension Nodes {
    struct CIZoomBlurNode: NodeImplProvider {
        public static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CIZoomBlur",
                inputs: [
                    .init(name: "inputImage", type: .image),
                    .init(name: "center", defaultValue: .vector2(Vector2(x: 150.0, y: 150.0))),
                    .init(name: "amount", defaultValue: .float(20.0)),
                ],
                outputs: [
                    .init(
                        name: "outputImage",
                        type: .image
                    )
                ]
            )

            return NodeImpl(schema: schema) { node, context in
                let filter = CIFilter.zoomBlur()
                filter.inputImage = await context.getImage(node.inputs[0].image)
                filter.center = node.inputs[1].vector2.cgPoint
                filter.amount = Float(node.inputs[2].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, id: .nodeOutput(node.id, 0)))
            }

        }
    }
}
