import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import Values

public enum CIFilterNodeKind: Sendable, Hashable, Codable {
    case blur(BlurNodeKind)
    case colorAdjustment(ColoradjustmentNodeKind)
    case colorEffect(ColoreffectNodeKind)
    case compositeOperation(CompositeoperationNodeKind)
    case distortionEffect(DistortioneffectNodeKind)
    case generator(GeneratorNodeKind)
    case geometryAdjustment(GeometryadjustmentNodeKind)
    case gradient(GradientNodeKind)
    case halftoneEffect(HalftoneeffectNodeKind)
    case reduction(ReductionNodeKind)
    case sharpen(SharpenNodeKind)
    case stylize(StylizeNodeKind)
    case tileEffect(TileeffectNodeKind)
    case transition(TransitionNodeKind)
    case video(VideoNodeKind)
    public var impl: NodeImpl {
        switch self {
        case .blur(let kind):
            kind.impl
        case .colorAdjustment(let kind):
            kind.impl
        case .colorEffect(let kind):
            kind.impl
        case .compositeOperation(let kind):
            kind.impl
        case .distortionEffect(let kind):
            kind.impl
        case .generator(let kind):
            kind.impl
        case .geometryAdjustment(let kind):
            kind.impl
        case .gradient(let kind):
            kind.impl
        case .halftoneEffect(let kind):
            kind.impl
        case .reduction(let kind):
            kind.impl
        case .sharpen(let kind):
            kind.impl
        case .stylize(let kind):
            kind.impl
        case .tileEffect(let kind):
            kind.impl
        case .transition(let kind):
            kind.impl
        case .video(let kind):
            kind.impl
        }
    }
    public enum BlurNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIBokehBlur
        case CIBoxBlur
        case CIDiscBlur
        case CIGaussianBlur
        case CIMaskedVariableBlur
        case CIMedianFilter
        case CIMorphologyGradient
        case CIMorphologyMaximum
        case CIMorphologyMinimum
        case CIMorphologyRectangleMaximum
        case CIMorphologyRectangleMinimum
        case CIMotionBlur
        case CINoiseReduction
        case CIZoomBlur
        public var impl: NodeImpl {
            switch self {
            case .CIBokehBlur:
                Nodes.CIBokehBlurNode.impl()
            case .CIBoxBlur:
                Nodes.CIBoxBlurNode.impl()
            case .CIDiscBlur:
                Nodes.CIDiscBlurNode.impl()
            case .CIGaussianBlur:
                Nodes.CIGaussianBlurNode.impl()
            case .CIMaskedVariableBlur:
                Nodes.CIMaskedVariableBlurNode.impl()
            case .CIMedianFilter:
                Nodes.CIMedianFilterNode.impl()
            case .CIMorphologyGradient:
                Nodes.CIMorphologyGradientNode.impl()
            case .CIMorphologyMaximum:
                Nodes.CIMorphologyMaximumNode.impl()
            case .CIMorphologyMinimum:
                Nodes.CIMorphologyMinimumNode.impl()
            case .CIMorphologyRectangleMaximum:
                Nodes.CIMorphologyRectangleMaximumNode.impl()
            case .CIMorphologyRectangleMinimum:
                Nodes.CIMorphologyRectangleMinimumNode.impl()
            case .CIMotionBlur:
                Nodes.CIMotionBlurNode.impl()
            case .CINoiseReduction:
                Nodes.CINoiseReductionNode.impl()
            case .CIZoomBlur:
                Nodes.CIZoomBlurNode.impl()
            }
        }
    }
    public enum ColoradjustmentNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIColorAbsoluteDifference
        case CIColorClamp
        case CIColorControls
        case CIColorMatrix
        case CIColorPolynomial
        case CIColorThreshold
        case CIColorThresholdOtsu
        case CIDepthToDisparity
        case CIDisparityToDepth
        case CIExposureAdjust
        case CIGammaAdjust
        case CIHueAdjust
        case CILinearToSRGBToneCurve
        case CISRGBToneCurveToLinear
        case CITemperatureAndTint
        case CIToneCurve
        case CIToneMapHeadroom
        case CIVibrance
        case CIWhitePointAdjust
        public var impl: NodeImpl {
            switch self {
            case .CIColorAbsoluteDifference:
                Nodes.CIColorAbsoluteDifferenceNode.impl()
            case .CIColorClamp:
                Nodes.CIColorClampNode.impl()
            case .CIColorControls:
                Nodes.CIColorControlsNode.impl()
            case .CIColorMatrix:
                Nodes.CIColorMatrixNode.impl()
            case .CIColorPolynomial:
                Nodes.CIColorPolynomialNode.impl()
            case .CIColorThreshold:
                Nodes.CIColorThresholdNode.impl()
            case .CIColorThresholdOtsu:
                Nodes.CIColorThresholdOtsuNode.impl()
            case .CIDepthToDisparity:
                Nodes.CIDepthToDisparityNode.impl()
            case .CIDisparityToDepth:
                Nodes.CIDisparityToDepthNode.impl()
            case .CIExposureAdjust:
                Nodes.CIExposureAdjustNode.impl()
            case .CIGammaAdjust:
                Nodes.CIGammaAdjustNode.impl()
            case .CIHueAdjust:
                Nodes.CIHueAdjustNode.impl()
            case .CILinearToSRGBToneCurve:
                Nodes.CILinearToSRGBToneCurveNode.impl()
            case .CISRGBToneCurveToLinear:
                Nodes.CISRGBToneCurveToLinearNode.impl()
            case .CITemperatureAndTint:
                Nodes.CITemperatureAndTintNode.impl()
            case .CIToneCurve:
                Nodes.CIToneCurveNode.impl()
            case .CIToneMapHeadroom:
                Nodes.CIToneMapHeadroomNode.impl()
            case .CIVibrance:
                Nodes.CIVibranceNode.impl()
            case .CIWhitePointAdjust:
                Nodes.CIWhitePointAdjustNode.impl()
            }
        }
    }
    public enum ColoreffectNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIColorCurves
        case CIColorInvert
        case CIColorMap
        case CIColorMonochrome
        case CIColorPosterize
        case CIConvertLabToRGB
        case CIConvertRGBtoLab
        case CIDither
        case CIDocumentEnhancer
        case CIFalseColor
        case CILabDeltaE
        case CIMaskToAlpha
        case CIMaximumComponent
        case CIMinimumComponent
        case CIPalettize
        case CIPhotoEffectChrome
        case CIPhotoEffectFade
        case CIPhotoEffectInstant
        case CIPhotoEffectMono
        case CIPhotoEffectNoir
        case CIPhotoEffectProcess
        case CIPhotoEffectTonal
        case CIPhotoEffectTransfer
        case CISepiaTone
        case CIThermal
        case CIVignette
        case CIVignetteEffect
        case CIXRay
        public var impl: NodeImpl {
            switch self {
            case .CIColorCurves:
                Nodes.CIColorCurvesNode.impl()
            case .CIColorInvert:
                Nodes.CIColorInvertNode.impl()
            case .CIColorMap:
                Nodes.CIColorMapNode.impl()
            case .CIColorMonochrome:
                Nodes.CIColorMonochromeNode.impl()
            case .CIColorPosterize:
                Nodes.CIColorPosterizeNode.impl()
            case .CIConvertLabToRGB:
                Nodes.CIConvertLabToRGBNode.impl()
            case .CIConvertRGBtoLab:
                Nodes.CIConvertRGBtoLabNode.impl()
            case .CIDither:
                Nodes.CIDitherNode.impl()
            case .CIDocumentEnhancer:
                Nodes.CIDocumentEnhancerNode.impl()
            case .CIFalseColor:
                Nodes.CIFalseColorNode.impl()
            case .CILabDeltaE:
                Nodes.CILabDeltaENode.impl()
            case .CIMaskToAlpha:
                Nodes.CIMaskToAlphaNode.impl()
            case .CIMaximumComponent:
                Nodes.CIMaximumComponentNode.impl()
            case .CIMinimumComponent:
                Nodes.CIMinimumComponentNode.impl()
            case .CIPalettize:
                Nodes.CIPalettizeNode.impl()
            case .CIPhotoEffectChrome:
                Nodes.CIPhotoEffectChromeNode.impl()
            case .CIPhotoEffectFade:
                Nodes.CIPhotoEffectFadeNode.impl()
            case .CIPhotoEffectInstant:
                Nodes.CIPhotoEffectInstantNode.impl()
            case .CIPhotoEffectMono:
                Nodes.CIPhotoEffectMonoNode.impl()
            case .CIPhotoEffectNoir:
                Nodes.CIPhotoEffectNoirNode.impl()
            case .CIPhotoEffectProcess:
                Nodes.CIPhotoEffectProcessNode.impl()
            case .CIPhotoEffectTonal:
                Nodes.CIPhotoEffectTonalNode.impl()
            case .CIPhotoEffectTransfer:
                Nodes.CIPhotoEffectTransferNode.impl()
            case .CISepiaTone:
                Nodes.CISepiaToneNode.impl()
            case .CIThermal:
                Nodes.CIThermalNode.impl()
            case .CIVignette:
                Nodes.CIVignetteNode.impl()
            case .CIVignetteEffect:
                Nodes.CIVignetteEffectNode.impl()
            case .CIXRay:
                Nodes.CIXRayNode.impl()
            }
        }
    }
    public enum CompositeoperationNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIAdditionCompositing
        case CIColorBlendMode
        case CIColorBurnBlendMode
        case CIColorDodgeBlendMode
        case CIDarkenBlendMode
        case CIDifferenceBlendMode
        case CIDivideBlendMode
        case CIExclusionBlendMode
        case CIHardLightBlendMode
        case CIHueBlendMode
        case CILightenBlendMode
        case CILinearBurnBlendMode
        case CILinearDodgeBlendMode
        case CILinearLightBlendMode
        case CILuminosityBlendMode
        case CIMaximumCompositing
        case CIMinimumCompositing
        case CIMultiplyBlendMode
        case CIMultiplyCompositing
        case CIOverlayBlendMode
        case CIPinLightBlendMode
        case CISaturationBlendMode
        case CIScreenBlendMode
        case CISoftLightBlendMode
        case CISourceAtopCompositing
        case CISourceInCompositing
        case CISourceOutCompositing
        case CISourceOverCompositing
        case CISubtractBlendMode
        case CIVividLightBlendMode
        public var impl: NodeImpl {
            switch self {
            case .CIAdditionCompositing:
                Nodes.CIAdditionCompositingNode.impl()
            case .CIColorBlendMode:
                Nodes.CIColorBlendModeNode.impl()
            case .CIColorBurnBlendMode:
                Nodes.CIColorBurnBlendModeNode.impl()
            case .CIColorDodgeBlendMode:
                Nodes.CIColorDodgeBlendModeNode.impl()
            case .CIDarkenBlendMode:
                Nodes.CIDarkenBlendModeNode.impl()
            case .CIDifferenceBlendMode:
                Nodes.CIDifferenceBlendModeNode.impl()
            case .CIDivideBlendMode:
                Nodes.CIDivideBlendModeNode.impl()
            case .CIExclusionBlendMode:
                Nodes.CIExclusionBlendModeNode.impl()
            case .CIHardLightBlendMode:
                Nodes.CIHardLightBlendModeNode.impl()
            case .CIHueBlendMode:
                Nodes.CIHueBlendModeNode.impl()
            case .CILightenBlendMode:
                Nodes.CILightenBlendModeNode.impl()
            case .CILinearBurnBlendMode:
                Nodes.CILinearBurnBlendModeNode.impl()
            case .CILinearDodgeBlendMode:
                Nodes.CILinearDodgeBlendModeNode.impl()
            case .CILinearLightBlendMode:
                Nodes.CILinearLightBlendModeNode.impl()
            case .CILuminosityBlendMode:
                Nodes.CILuminosityBlendModeNode.impl()
            case .CIMaximumCompositing:
                Nodes.CIMaximumCompositingNode.impl()
            case .CIMinimumCompositing:
                Nodes.CIMinimumCompositingNode.impl()
            case .CIMultiplyBlendMode:
                Nodes.CIMultiplyBlendModeNode.impl()
            case .CIMultiplyCompositing:
                Nodes.CIMultiplyCompositingNode.impl()
            case .CIOverlayBlendMode:
                Nodes.CIOverlayBlendModeNode.impl()
            case .CIPinLightBlendMode:
                Nodes.CIPinLightBlendModeNode.impl()
            case .CISaturationBlendMode:
                Nodes.CISaturationBlendModeNode.impl()
            case .CIScreenBlendMode:
                Nodes.CIScreenBlendModeNode.impl()
            case .CISoftLightBlendMode:
                Nodes.CISoftLightBlendModeNode.impl()
            case .CISourceAtopCompositing:
                Nodes.CISourceAtopCompositingNode.impl()
            case .CISourceInCompositing:
                Nodes.CISourceInCompositingNode.impl()
            case .CISourceOutCompositing:
                Nodes.CISourceOutCompositingNode.impl()
            case .CISourceOverCompositing:
                Nodes.CISourceOverCompositingNode.impl()
            case .CISubtractBlendMode:
                Nodes.CISubtractBlendModeNode.impl()
            case .CIVividLightBlendMode:
                Nodes.CIVividLightBlendModeNode.impl()
            }
        }
    }
    public enum DistortioneffectNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIBumpDistortion
        case CIBumpDistortionLinear
        case CICircleSplashDistortion
        case CICircularWrap
        case CIDisplacementDistortion
        case CIDroste
        case CIGlassDistortion
        case CIGlassLozenge
        case CIHoleDistortion
        case CILightTunnel
        case CINinePartStretched
        case CINinePartTiled
        case CIPinchDistortion
        case CIStretchCrop
        case CITorusLensDistortion
        case CITwirlDistortion
        case CIVortexDistortion
        public var impl: NodeImpl {
            switch self {
            case .CIBumpDistortion:
                Nodes.CIBumpDistortionNode.impl()
            case .CIBumpDistortionLinear:
                Nodes.CIBumpDistortionLinearNode.impl()
            case .CICircleSplashDistortion:
                Nodes.CICircleSplashDistortionNode.impl()
            case .CICircularWrap:
                Nodes.CICircularWrapNode.impl()
            case .CIDisplacementDistortion:
                Nodes.CIDisplacementDistortionNode.impl()
            case .CIDroste:
                Nodes.CIDrosteNode.impl()
            case .CIGlassDistortion:
                Nodes.CIGlassDistortionNode.impl()
            case .CIGlassLozenge:
                Nodes.CIGlassLozengeNode.impl()
            case .CIHoleDistortion:
                Nodes.CIHoleDistortionNode.impl()
            case .CILightTunnel:
                Nodes.CILightTunnelNode.impl()
            case .CINinePartStretched:
                Nodes.CINinePartStretchedNode.impl()
            case .CINinePartTiled:
                Nodes.CINinePartTiledNode.impl()
            case .CIPinchDistortion:
                Nodes.CIPinchDistortionNode.impl()
            case .CIStretchCrop:
                Nodes.CIStretchCropNode.impl()
            case .CITorusLensDistortion:
                Nodes.CITorusLensDistortionNode.impl()
            case .CITwirlDistortion:
                Nodes.CITwirlDistortionNode.impl()
            case .CIVortexDistortion:
                Nodes.CIVortexDistortionNode.impl()
            }
        }
    }
    public enum GeneratorNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIAttributedTextImageGenerator
        case CIBlurredRectangleGenerator
        case CIBlurredRoundedRectangleGenerator
        case CICheckerboardGenerator
        case CIConstantColorGenerator
        case CILenticularHaloGenerator
        case CIQRCodeGenerator
        case CIRandomGenerator
        case CIRoundedQRCodeGenerator
        case CIRoundedRectangleGenerator
        case CIRoundedRectangleStrokeGenerator
        case CIStarShineGenerator
        case CIStripesGenerator
        case CISunbeamsGenerator
        case CITextImageGenerator
        public var impl: NodeImpl {
            switch self {
            case .CIAttributedTextImageGenerator:
                Nodes.CIAttributedTextImageGeneratorNode.impl()
            case .CIBlurredRectangleGenerator:
                Nodes.CIBlurredRectangleGeneratorNode.impl()
            case .CIBlurredRoundedRectangleGenerator:
                Nodes.CIBlurredRoundedRectangleGeneratorNode.impl()
            case .CICheckerboardGenerator:
                Nodes.CICheckerboardGeneratorNode.impl()
            case .CIConstantColorGenerator:
                Nodes.CIConstantColorGeneratorNode.impl()
            case .CILenticularHaloGenerator:
                Nodes.CILenticularHaloGeneratorNode.impl()
            case .CIQRCodeGenerator:
                Nodes.CIQRCodeGeneratorNode.impl()
            case .CIRandomGenerator:
                Nodes.CIRandomGeneratorNode.impl()
            case .CIRoundedQRCodeGenerator:
                Nodes.CIRoundedQRCodeGeneratorNode.impl()
            case .CIRoundedRectangleGenerator:
                Nodes.CIRoundedRectangleGeneratorNode.impl()
            case .CIRoundedRectangleStrokeGenerator:
                Nodes.CIRoundedRectangleStrokeGeneratorNode.impl()
            case .CIStarShineGenerator:
                Nodes.CIStarShineGeneratorNode.impl()
            case .CIStripesGenerator:
                Nodes.CIStripesGeneratorNode.impl()
            case .CISunbeamsGenerator:
                Nodes.CISunbeamsGeneratorNode.impl()
            case .CITextImageGenerator:
                Nodes.CITextImageGeneratorNode.impl()
            }
        }
    }
    public enum GeometryadjustmentNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIAffineTransform
        case CIBicubicScaleTransform
        case CICrop
        case CIEdgePreserveUpsampleFilter
        case CIGuidedFilter
        case CIKeystoneCorrectionCombined
        case CIKeystoneCorrectionHorizontal
        case CIKeystoneCorrectionVertical
        case CILanczosScaleTransform
        case CIMaximumScaleTransform
        case CIPerspectiveCorrection
        case CIPerspectiveRotate
        case CIPerspectiveTransform
        case CIPerspectiveTransformWithExtent
        case CIStraightenFilter
        public var impl: NodeImpl {
            switch self {
            case .CIAffineTransform:
                Nodes.CIAffineTransformNode.impl()
            case .CIBicubicScaleTransform:
                Nodes.CIBicubicScaleTransformNode.impl()
            case .CICrop:
                Nodes.CICropNode.impl()
            case .CIEdgePreserveUpsampleFilter:
                Nodes.CIEdgePreserveUpsampleFilterNode.impl()
            case .CIGuidedFilter:
                Nodes.CIGuidedFilterNode.impl()
            case .CIKeystoneCorrectionCombined:
                Nodes.CIKeystoneCorrectionCombinedNode.impl()
            case .CIKeystoneCorrectionHorizontal:
                Nodes.CIKeystoneCorrectionHorizontalNode.impl()
            case .CIKeystoneCorrectionVertical:
                Nodes.CIKeystoneCorrectionVerticalNode.impl()
            case .CILanczosScaleTransform:
                Nodes.CILanczosScaleTransformNode.impl()
            case .CIMaximumScaleTransform:
                Nodes.CIMaximumScaleTransformNode.impl()
            case .CIPerspectiveCorrection:
                Nodes.CIPerspectiveCorrectionNode.impl()
            case .CIPerspectiveRotate:
                Nodes.CIPerspectiveRotateNode.impl()
            case .CIPerspectiveTransform:
                Nodes.CIPerspectiveTransformNode.impl()
            case .CIPerspectiveTransformWithExtent:
                Nodes.CIPerspectiveTransformWithExtentNode.impl()
            case .CIStraightenFilter:
                Nodes.CIStraightenFilterNode.impl()
            }
        }
    }
    public enum GradientNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIDistanceGradientFromRedMask
        case CIGaussianGradient
        case CIHueSaturationValueGradient
        case CILinearGradient
        case CIRadialGradient
        case CISignedDistanceGradientFromRedMask
        case CISmoothLinearGradient
        public var impl: NodeImpl {
            switch self {
            case .CIDistanceGradientFromRedMask:
                Nodes.CIDistanceGradientFromRedMaskNode.impl()
            case .CIGaussianGradient:
                Nodes.CIGaussianGradientNode.impl()
            case .CIHueSaturationValueGradient:
                Nodes.CIHueSaturationValueGradientNode.impl()
            case .CILinearGradient:
                Nodes.CILinearGradientNode.impl()
            case .CIRadialGradient:
                Nodes.CIRadialGradientNode.impl()
            case .CISignedDistanceGradientFromRedMask:
                Nodes.CISignedDistanceGradientFromRedMaskNode.impl()
            case .CISmoothLinearGradient:
                Nodes.CISmoothLinearGradientNode.impl()
            }
        }
    }
    public enum HalftoneeffectNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CICircularScreen
        case CICMYKHalftone
        case CIDotScreen
        case CIHatchedScreen
        case CILineScreen
        public var impl: NodeImpl {
            switch self {
            case .CICircularScreen:
                Nodes.CICircularScreenNode.impl()
            case .CICMYKHalftone:
                Nodes.CICMYKHalftoneNode.impl()
            case .CIDotScreen:
                Nodes.CIDotScreenNode.impl()
            case .CIHatchedScreen:
                Nodes.CIHatchedScreenNode.impl()
            case .CILineScreen:
                Nodes.CILineScreenNode.impl()
            }
        }
    }
    public enum ReductionNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIAreaAlphaWeightedHistogram
        case CIAreaAverage
        case CIAreaAverageMaximumRed
        case CIAreaBoundsRed
        case CIAreaHistogram
        case CIAreaLogarithmicHistogram
        case CIAreaMaximum
        case CIAreaMaximumAlpha
        case CIAreaMinimum
        case CIAreaMinimumAlpha
        case CIAreaMinMax
        case CIAreaMinMaxRed
        case CIColumnAverage
        case CIHistogramDisplayFilter
        case CIKMeans
        case CIRowAverage
        public var impl: NodeImpl {
            switch self {
            case .CIAreaAlphaWeightedHistogram:
                Nodes.CIAreaAlphaWeightedHistogramNode.impl()
            case .CIAreaAverage:
                Nodes.CIAreaAverageNode.impl()
            case .CIAreaAverageMaximumRed:
                Nodes.CIAreaAverageMaximumRedNode.impl()
            case .CIAreaBoundsRed:
                Nodes.CIAreaBoundsRedNode.impl()
            case .CIAreaHistogram:
                Nodes.CIAreaHistogramNode.impl()
            case .CIAreaLogarithmicHistogram:
                Nodes.CIAreaLogarithmicHistogramNode.impl()
            case .CIAreaMaximum:
                Nodes.CIAreaMaximumNode.impl()
            case .CIAreaMaximumAlpha:
                Nodes.CIAreaMaximumAlphaNode.impl()
            case .CIAreaMinimum:
                Nodes.CIAreaMinimumNode.impl()
            case .CIAreaMinimumAlpha:
                Nodes.CIAreaMinimumAlphaNode.impl()
            case .CIAreaMinMax:
                Nodes.CIAreaMinMaxNode.impl()
            case .CIAreaMinMaxRed:
                Nodes.CIAreaMinMaxRedNode.impl()
            case .CIColumnAverage:
                Nodes.CIColumnAverageNode.impl()
            case .CIHistogramDisplayFilter:
                Nodes.CIHistogramDisplayFilterNode.impl()
            case .CIKMeans:
                Nodes.CIKMeansNode.impl()
            case .CIRowAverage:
                Nodes.CIRowAverageNode.impl()
            }
        }
    }
    public enum SharpenNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CISharpenLuminance
        case CIUnsharpMask
        public var impl: NodeImpl {
            switch self {
            case .CISharpenLuminance:
                Nodes.CISharpenLuminanceNode.impl()
            case .CIUnsharpMask:
                Nodes.CIUnsharpMaskNode.impl()
            }
        }
    }
    public enum StylizeNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIBlendWithAlphaMask
        case CIBlendWithBlueMask
        case CIBlendWithMask
        case CIBlendWithRedMask
        case CIBloom
        case CICannyEdgeDetector
        case CIComicEffect
        case CIConvolution3X3
        case CIConvolution5X5
        case CIConvolution7X7
        case CIConvolution9Horizontal
        case CIConvolution9Vertical
        case CIConvolutionRGB3X3
        case CIConvolutionRGB5X5
        case CIConvolutionRGB7X7
        case CIConvolutionRGB9Horizontal
        case CIConvolutionRGB9Vertical
        case CICrystallize
        case CIDepthOfField
        case CIEdges
        case CIEdgeWork
        case CIGaborGradients
        case CIGloom
        case CIHeightFieldFromMask
        case CIHexagonalPixellate
        case CIHighlightShadowAdjust
        case CILineOverlay
        case CIMix
        case CIPixellate
        case CIPointillize
        case CISampleNearest
        case CIShadedMaterial
        case CISobelGradients
        case CISpotColor
        case CISpotLight
        public var impl: NodeImpl {
            switch self {
            case .CIBlendWithAlphaMask:
                Nodes.CIBlendWithAlphaMaskNode.impl()
            case .CIBlendWithBlueMask:
                Nodes.CIBlendWithBlueMaskNode.impl()
            case .CIBlendWithMask:
                Nodes.CIBlendWithMaskNode.impl()
            case .CIBlendWithRedMask:
                Nodes.CIBlendWithRedMaskNode.impl()
            case .CIBloom:
                Nodes.CIBloomNode.impl()
            case .CICannyEdgeDetector:
                Nodes.CICannyEdgeDetectorNode.impl()
            case .CIComicEffect:
                Nodes.CIComicEffectNode.impl()
            case .CIConvolution3X3:
                Nodes.CIConvolution3X3Node.impl()
            case .CIConvolution5X5:
                Nodes.CIConvolution5X5Node.impl()
            case .CIConvolution7X7:
                Nodes.CIConvolution7X7Node.impl()
            case .CIConvolution9Horizontal:
                Nodes.CIConvolution9HorizontalNode.impl()
            case .CIConvolution9Vertical:
                Nodes.CIConvolution9VerticalNode.impl()
            case .CIConvolutionRGB3X3:
                Nodes.CIConvolutionRGB3X3Node.impl()
            case .CIConvolutionRGB5X5:
                Nodes.CIConvolutionRGB5X5Node.impl()
            case .CIConvolutionRGB7X7:
                Nodes.CIConvolutionRGB7X7Node.impl()
            case .CIConvolutionRGB9Horizontal:
                Nodes.CIConvolutionRGB9HorizontalNode.impl()
            case .CIConvolutionRGB9Vertical:
                Nodes.CIConvolutionRGB9VerticalNode.impl()
            case .CICrystallize:
                Nodes.CICrystallizeNode.impl()
            case .CIDepthOfField:
                Nodes.CIDepthOfFieldNode.impl()
            case .CIEdges:
                Nodes.CIEdgesNode.impl()
            case .CIEdgeWork:
                Nodes.CIEdgeWorkNode.impl()
            case .CIGaborGradients:
                Nodes.CIGaborGradientsNode.impl()
            case .CIGloom:
                Nodes.CIGloomNode.impl()
            case .CIHeightFieldFromMask:
                Nodes.CIHeightFieldFromMaskNode.impl()
            case .CIHexagonalPixellate:
                Nodes.CIHexagonalPixellateNode.impl()
            case .CIHighlightShadowAdjust:
                Nodes.CIHighlightShadowAdjustNode.impl()
            case .CILineOverlay:
                Nodes.CILineOverlayNode.impl()
            case .CIMix:
                Nodes.CIMixNode.impl()
            case .CIPixellate:
                Nodes.CIPixellateNode.impl()
            case .CIPointillize:
                Nodes.CIPointillizeNode.impl()
            case .CISampleNearest:
                Nodes.CISampleNearestNode.impl()
            case .CIShadedMaterial:
                Nodes.CIShadedMaterialNode.impl()
            case .CISobelGradients:
                Nodes.CISobelGradientsNode.impl()
            case .CISpotColor:
                Nodes.CISpotColorNode.impl()
            case .CISpotLight:
                Nodes.CISpotLightNode.impl()
            }
        }
    }
    public enum TileeffectNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIAffineClamp
        case CIAffineTile
        case CIClamp
        case CIEightfoldReflectedTile
        case CIFourfoldReflectedTile
        case CIFourfoldRotatedTile
        case CIFourfoldTranslatedTile
        case CIGlideReflectedTile
        case CIKaleidoscope
        case CIOpTile
        case CIParallelogramTile
        case CIPerspectiveTile
        case CISixfoldReflectedTile
        case CISixfoldRotatedTile
        case CITriangleKaleidoscope
        case CITriangleTile
        case CITwelvefoldReflectedTile
        public var impl: NodeImpl {
            switch self {
            case .CIAffineClamp:
                Nodes.CIAffineClampNode.impl()
            case .CIAffineTile:
                Nodes.CIAffineTileNode.impl()
            case .CIClamp:
                Nodes.CIClampNode.impl()
            case .CIEightfoldReflectedTile:
                Nodes.CIEightfoldReflectedTileNode.impl()
            case .CIFourfoldReflectedTile:
                Nodes.CIFourfoldReflectedTileNode.impl()
            case .CIFourfoldRotatedTile:
                Nodes.CIFourfoldRotatedTileNode.impl()
            case .CIFourfoldTranslatedTile:
                Nodes.CIFourfoldTranslatedTileNode.impl()
            case .CIGlideReflectedTile:
                Nodes.CIGlideReflectedTileNode.impl()
            case .CIKaleidoscope:
                Nodes.CIKaleidoscopeNode.impl()
            case .CIOpTile:
                Nodes.CIOpTileNode.impl()
            case .CIParallelogramTile:
                Nodes.CIParallelogramTileNode.impl()
            case .CIPerspectiveTile:
                Nodes.CIPerspectiveTileNode.impl()
            case .CISixfoldReflectedTile:
                Nodes.CISixfoldReflectedTileNode.impl()
            case .CISixfoldRotatedTile:
                Nodes.CISixfoldRotatedTileNode.impl()
            case .CITriangleKaleidoscope:
                Nodes.CITriangleKaleidoscopeNode.impl()
            case .CITriangleTile:
                Nodes.CITriangleTileNode.impl()
            case .CITwelvefoldReflectedTile:
                Nodes.CITwelvefoldReflectedTileNode.impl()
            }
        }
    }
    public enum TransitionNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIAccordionFoldTransition
        case CIBarsSwipeTransition
        case CICopyMachineTransition
        case CIDisintegrateWithMaskTransition
        case CIDissolveTransition
        case CIFlashTransition
        case CIModTransition
        case CIPageCurlTransition
        case CIPageCurlWithShadowTransition
        case CIRippleTransition
        case CISwipeTransition
        public var impl: NodeImpl {
            switch self {
            case .CIAccordionFoldTransition:
                Nodes.CIAccordionFoldTransitionNode.impl()
            case .CIBarsSwipeTransition:
                Nodes.CIBarsSwipeTransitionNode.impl()
            case .CICopyMachineTransition:
                Nodes.CICopyMachineTransitionNode.impl()
            case .CIDisintegrateWithMaskTransition:
                Nodes.CIDisintegrateWithMaskTransitionNode.impl()
            case .CIDissolveTransition:
                Nodes.CIDissolveTransitionNode.impl()
            case .CIFlashTransition:
                Nodes.CIFlashTransitionNode.impl()
            case .CIModTransition:
                Nodes.CIModTransitionNode.impl()
            case .CIPageCurlTransition:
                Nodes.CIPageCurlTransitionNode.impl()
            case .CIPageCurlWithShadowTransition:
                Nodes.CIPageCurlWithShadowTransitionNode.impl()
            case .CIRippleTransition:
                Nodes.CIRippleTransitionNode.impl()
            case .CISwipeTransition:
                Nodes.CISwipeTransitionNode.impl()
            }
        }
    }
    public enum VideoNodeKind: Sendable, Hashable, Codable, CaseIterable {
        case CIPersonSegmentation
        case CISaliencyMapFilter
        public var impl: NodeImpl {
            switch self {
            case .CIPersonSegmentation:
                Nodes.CIPersonSegmentationNode.impl()
            case .CISaliencyMapFilter:
                Nodes.CISaliencyMapFilterNode.impl()
            }
        }
    }
}
extension Nodes {

    public struct CIAccordionFoldTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Accordion Fold Transition",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Bottom Height", defaultValue: .float(0.0), semantics: .distance),
                    .init(name: "Number of Folds", defaultValue: .int(3), semantics: .count),
                    .init(name: "Fold Shadow Amount", defaultValue: .float(0.1), semantics: .default),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAccordionFoldTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(node.inputs[2].float, forKey: "inputBottomHeight")
                filter.setValue(node.inputs[3].int, forKey: "inputNumberOfFolds")
                filter.setValue(node.inputs[4].float, forKey: "inputFoldShadowAmount")
                filter.setValue(node.inputs[5].float, forKey: "inputTime")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAdditionCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Addition",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAdditionCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAffineClampNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Affine Clamp",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Transform",
                        defaultValue: .affineTransform(.init(m11: 0.4, m12: 0.0, m21: 0.0, m22: 0.4, tX: 0.0, tY: 0.0)),
                        semantics: .transform
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAffineClamp")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                #if os(macOS)
                filter.setValue(node.inputs[1].affineTransform.fAffineTransform, forKey: "inputTransform")
                #else
                filter.setValue(node.inputs[1].affineTransform.nsValue, forKey: "inputTransform")
                #endif
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAffineTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Affine Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Transform",
                        defaultValue: .affineTransform(.init(m11: 0.4, m12: 0.0, m21: 0.0, m22: 0.4, tX: 0.0, tY: 0.0)),
                        semantics: .transform
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAffineTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                #if os(macOS)
                filter.setValue(node.inputs[1].affineTransform.fAffineTransform, forKey: "inputTransform")
                #else
                filter.setValue(node.inputs[1].affineTransform.nsValue, forKey: "inputTransform")
                #endif
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAffineTransformNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Affine Transform",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Transform",
                        defaultValue: .affineTransform(.init(m11: 1.0, m12: 0.0, m21: 0.0, m22: 1.0, tX: 0.0, tY: 0.0)),
                        semantics: .transform
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAffineTransform")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                #if os(macOS)
                filter.setValue(node.inputs[1].affineTransform.fAffineTransform, forKey: "inputTransform")
                #else
                filter.setValue(node.inputs[1].affineTransform.nsValue, forKey: "inputTransform")
                #endif
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaAlphaWeightedHistogramNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Alpha Weighted Histogram",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Scale", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Count", defaultValue: .int(64), semantics: .count),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaAlphaWeightedHistogram")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                filter.setValue(node.inputs[3].int, forKey: "inputCount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaAverageNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Average",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaAverage")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaAverageMaximumRedNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Average and Maximum Red",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaAverageMaximumRed")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaBoundsRedNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Bounds Red",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaBoundsRed")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaHistogramNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Histogram",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Scale", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Count", defaultValue: .int(64), semantics: .count),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaHistogram")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                filter.setValue(node.inputs[3].int, forKey: "inputCount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaLogarithmicHistogramNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Logarithmic Histogram",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Scale", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Count", defaultValue: .int(64), semantics: .count),
                    .init(name: "Minimum Stop", defaultValue: .float(-10.0), semantics: .default),
                    .init(name: "Maximum Stop", defaultValue: .float(4.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaLogarithmicHistogram")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                filter.setValue(node.inputs[3].int, forKey: "inputCount")
                filter.setValue(node.inputs[4].float, forKey: "inputMinimumStop")
                filter.setValue(node.inputs[5].float, forKey: "inputMaximumStop")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaMaximumNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Maximum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaMaximum")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaMaximumAlphaNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Maximum Alpha",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaMaximumAlpha")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaMinimumNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Minimum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaMinimum")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaMinimumAlphaNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Minimum Alpha",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaMinimumAlpha")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaMinMaxNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Min and Max",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaMinMax")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAreaMinMaxRedNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Area Min and Max Red",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAreaMinMaxRed")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIAttributedTextImageGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Attributed Text Image Generator",
                inputs: [
                    .init(name: "Text", type: .attributedString, semantics: .default),
                    .init(name: "Scale Factor", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Padding", defaultValue: .int(0), semantics: .integer),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIAttributedTextImageGenerator")!
                filter.setValue(NSAttributedString(node.inputs[0].attributedString), forKey: "inputText")
                filter.setValue(node.inputs[1].float, forKey: "inputScaleFactor")
                filter.setValue(node.inputs[2].int, forKey: "inputPadding")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBarsSwipeTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bars Swipe Transition",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Angle", defaultValue: .float(3.141592653589793), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(30.0), semantics: .distance),
                    .init(name: "Bar Offset", defaultValue: .float(10.0), semantics: .default),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBarsSwipeTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputBarOffset")
                filter.setValue(node.inputs[5].float, forKey: "inputTime")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBicubicScaleTransformNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bicubic Scale Transform",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Scale", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Aspect Ratio", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "B", defaultValue: .float(0.0), semantics: .default),
                    .init(name: "C", defaultValue: .float(0.75), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBicubicScaleTransform")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputScale")
                filter.setValue(node.inputs[2].float, forKey: "inputAspectRatio")
                filter.setValue(node.inputs[3].float, forKey: "inputB")
                filter.setValue(node.inputs[4].float, forKey: "inputC")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBlendWithAlphaMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blend With Alpha Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                    .init(name: "Mask Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBlendWithAlphaMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputMaskImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBlendWithBlueMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blend With Blue Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                    .init(name: "Mask Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBlendWithBlueMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputMaskImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBlendWithMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blend With Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                    .init(name: "Mask Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBlendWithMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputMaskImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBlendWithRedMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blend With Red Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                    .init(name: "Mask Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBlendWithRedMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputMaskImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBloomNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bloom",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Intensity", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBloom")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBlurredRectangleGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blurred Rectangle Generator",
                inputs: [
                    .init(
                        name: "Extent",
                        defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 256.0, height: 256.0)),
                        semantics: .rectangle
                    ), .init(name: "Sigma", defaultValue: .float(10.0), semantics: .distance),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBlurredRectangleGenerator")!
                filter.setValue(CIVector(cgRect: node.inputs[0].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[1].float, forKey: "inputSigma")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBlurredRoundedRectangleGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blurred Rounded Rectangle Generator",
                inputs: [
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Smoothness", defaultValue: .float(0.0), semantics: .distance),
                    .init(name: "Sigma", defaultValue: .float(10.0), semantics: .distance),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBlurredRoundedRectangleGenerator")!
                filter.setValue(CIVector(cgRect: node.inputs[0].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputSmoothness")
                filter.setValue(node.inputs[3].float, forKey: "inputSigma")
                filter.setValue(node.inputs[4].color4.ciColor, forKey: "inputColor")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBokehBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bokeh Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(20.0), semantics: .distance),
                    .init(name: "Ring Amount", defaultValue: .float(0.0), semantics: .default),
                    .init(name: "Ring Size", defaultValue: .float(0.1), semantics: .default),
                    .init(name: "Softness", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBokehBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[5].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputRingAmount")
                filter.setValue(node.inputs[3].float, forKey: "inputRingSize")
                filter.setValue(node.inputs[4].float, forKey: "inputSoftness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[5].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBoxBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Box Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBoxBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[2].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[2].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBumpDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bump Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Scale", defaultValue: .float(0.5), semantics: .default),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBumpDistortion")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[4].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[4].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIBumpDistortionLinearNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bump Distortion Linear",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Scale", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIBumpDistortionLinear")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                filter.setValue(node.inputs[4].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICannyEdgeDetectorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Canny Edge Detector",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Gaussian Sigma", defaultValue: .float(1.6), semantics: .default),
                    .init(name: "Perceptual", defaultValue: .bool(false), semantics: .boolean),
                    .init(name: "Threshold High", defaultValue: .float(0.05), semantics: .default),
                    .init(name: "Threshold Low", defaultValue: .float(0.02), semantics: .default),
                    .init(name: "Hysteresis Passes", defaultValue: .int(1), semantics: .integer),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICannyEdgeDetector")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputGaussianSigma")
                filter.setValue(node.inputs[2].bool, forKey: "inputPerceptual")
                filter.setValue(node.inputs[3].float, forKey: "inputThresholdHigh")
                filter.setValue(node.inputs[4].float, forKey: "inputThresholdLow")
                filter.setValue(node.inputs[5].int, forKey: "inputHysteresisPasses")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICheckerboardGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Checkerboard",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Width", defaultValue: .float(80.0), semantics: .distance),
                    .init(name: "Sharpness", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICheckerboardGenerator")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor1")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICircleSplashDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Circle Splash Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(150.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICircleSplashDistortion")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICircularScreenNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Circular Screen",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Width", defaultValue: .float(6.0), semantics: .distance),
                    .init(name: "Sharpness", defaultValue: .float(0.7), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICircularScreen")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputWidth")
                filter.setValue(node.inputs[3].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICircularWrapNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Circular Wrap Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(150.0), semantics: .distance),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICircularWrap")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIClampNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Clamp",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIClamp")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICMYKHalftoneNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "CMYK Halftone",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Width", defaultValue: .float(6.0), semantics: .distance),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Sharpness", defaultValue: .float(0.7), semantics: .distance),
                    .init(name: "Gray Component Replacement", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Under Color Removal", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICMYKHalftone")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputWidth")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                filter.setValue(node.inputs[4].float, forKey: "inputSharpness")
                filter.setValue(node.inputs[5].float, forKey: "inputGCR")
                filter.setValue(node.inputs[6].float, forKey: "inputUCR")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorAbsoluteDifferenceNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Absolute Difference",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Image2", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorAbsoluteDifference")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputImage2")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorBurnBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Burn Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorBurnBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorClampNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Clamp",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Min Components",
                        defaultValue: .vector4(.init(x: 0.0, y: 0.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Max Components",
                        defaultValue: .vector4(.init(x: 1.0, y: 1.0, z: 1.0, w: 1.0)),
                        semantics: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorClamp")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector4.ciVector, forKey: "inputMinComponents")
                filter.setValue(node.inputs[2].vector4.ciVector, forKey: "inputMaxComponents")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorControlsNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Controls",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Saturation", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Brightness", defaultValue: .float(0.0), semantics: .default),
                    .init(name: "Contrast", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorControls")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputSaturation")
                filter.setValue(node.inputs[2].float, forKey: "inputBrightness")
                filter.setValue(node.inputs[3].float, forKey: "inputContrast")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorCurvesNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Curves",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Curves Data",
                        defaultValue: .data(Data(base64Encoded: "AAAAAAAAAAAAAAAAAAAAPwAAAD8AAAA/AACAPwAAgD8AAIA/")!),
                        semantics: .default
                    ), .init(name: "Curves Domain", defaultValue: .vector2(.init(x: 0.0, y: 1.0)), semantics: .default),
                    .init(name: "Color Space", type: .colorSpace, semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorCurves")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].data, forKey: "inputCurvesData")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCurvesDomain")
                filter.setValue(node.inputs[3].colorSpace.cgColorSpace(), forKey: "inputColorSpace")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorDodgeBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Dodge Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorDodgeBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorInvertNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Invert",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorInvert")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorMapNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Map",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Gradient Image", type: .image, semantics: .gradient),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorMap")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputGradientImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorMatrixNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Matrix",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Red Vector",
                        defaultValue: .vector4(.init(x: 1.0, y: 0.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Green Vector",
                        defaultValue: .vector4(.init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Blue Vector",
                        defaultValue: .vector4(.init(x: 0.0, y: 0.0, z: 1.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Alpha Vector",
                        defaultValue: .vector4(.init(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Bias Vector",
                        defaultValue: .vector4(.init(x: 1.0, y: 0.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorMatrix")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector4.ciVector, forKey: "inputRVector")
                filter.setValue(node.inputs[2].vector4.ciVector, forKey: "inputGVector")
                filter.setValue(node.inputs[3].vector4.ciVector, forKey: "inputBVector")
                filter.setValue(node.inputs[4].vector4.ciVector, forKey: "inputAVector")
                filter.setValue(node.inputs[5].vector4.ciVector, forKey: "inputBiasVector")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorMonochromeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Monochrome",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Color",
                        defaultValue: .color3(.init(red: 0.6, green: 0.45, blue: 0.3)),
                        semantics: .opaqueColor
                    ), .init(name: "Intensity", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorMonochrome")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].color3.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[2].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorPolynomialNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Polynomial",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Red Coefficients",
                        defaultValue: .vector4(.init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Green Coefficients",
                        defaultValue: .vector4(.init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Blue Coefficients",
                        defaultValue: .vector4(.init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                    .init(
                        name: "Alpha Coefficients",
                        defaultValue: .vector4(.init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)),
                        semantics: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorPolynomial")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector4.ciVector, forKey: "inputRedCoefficients")
                filter.setValue(node.inputs[2].vector4.ciVector, forKey: "inputGreenCoefficients")
                filter.setValue(node.inputs[3].vector4.ciVector, forKey: "inputBlueCoefficients")
                filter.setValue(node.inputs[4].vector4.ciVector, forKey: "inputAlphaCoefficients")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorPosterizeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Posterize",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Levels", defaultValue: .float(6.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorPosterize")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputLevels")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorThresholdNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Threshold",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Threshold", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorThreshold")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputThreshold")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColorThresholdOtsuNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Threshold Otsu",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColorThresholdOtsu")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIColumnAverageNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Column Average",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIColumnAverage")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIComicEffectNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Comic Effect",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIComicEffect")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConstantColorGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Constant Color",
                inputs: [
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    )
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConstantColorGenerator")!
                filter.setValue(node.inputs[0].color4.ciColor, forKey: "inputColor")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvertLabToRGBNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Convert Lab to RGB",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Normalize", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvertLabToRGB")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputNormalize")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvertRGBtoLabNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Convert RGB to Lab",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Normalize", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvertRGBtoLab")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputNormalize")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution3X3Node: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "3 by 3 Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolution3X3")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution5X5Node: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "5 by 5 Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolution5X5")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution7X7Node: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "7 by 7 Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolution7X7")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution9HorizontalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Horizontal 9 Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolution9Horizontal")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution9VerticalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vertical 9 Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolution9Vertical")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolutionRGB3X3Node: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "3 by 3 RGB Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB3X3")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolutionRGB5X5Node: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "5 by 5 RGB Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB5X5")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolutionRGB7X7Node: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "7 by 7 RGB Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB7X7")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolutionRGB9HorizontalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Horizontal 9 RGB Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB9Horizontal")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolutionRGB9VerticalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vertical 9 RGB Convolution",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Weights", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .default),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB9Vertical")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputWeights")
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICopyMachineTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Copy Machine",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(
                        name: "Color",
                        defaultValue: .color3(.init(red: 0.6, green: 1.0, blue: 0.8)),
                        semantics: .opaqueColor
                    ), .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(200.0), semantics: .distance),
                    .init(name: "Opacity", defaultValue: .float(1.3), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICopyMachineTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(CIVector(cgRect: node.inputs[2].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[3].color3.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[4].float, forKey: "inputTime")
                filter.setValue(node.inputs[5].float, forKey: "inputAngle")
                filter.setValue(node.inputs[6].float, forKey: "inputWidth")
                filter.setValue(node.inputs[7].float, forKey: "inputOpacity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICropNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Crop",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Rectangle",
                        defaultValue: .rect(CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)),
                        semantics: .rectangle
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICrop")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputRectangle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CICrystallizeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Crystallize",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(20.0), semantics: .distance),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CICrystallize")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDarkenBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Darken Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDarkenBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDepthOfFieldNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Depth of Field",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Point 0", defaultValue: .vector2(.init(x: 0.0, y: 300.0)), semantics: .position2),
                    .init(name: "Point 1", defaultValue: .vector2(.init(x: 300.0, y: 300.0)), semantics: .position2),
                    .init(name: "Saturation", defaultValue: .float(1.5), semantics: .default),
                    .init(name: "Unsharp Mask Radius", defaultValue: .float(2.5), semantics: .distance),
                    .init(name: "Unsharp Mask Intensity", defaultValue: .float(0.5), semantics: .default),
                    .init(name: "Radius", defaultValue: .float(6.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDepthOfField")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputPoint0")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputPoint1")
                filter.setValue(node.inputs[3].float, forKey: "inputSaturation")
                filter.setValue(node.inputs[4].float, forKey: "inputUnsharpMaskRadius")
                filter.setValue(node.inputs[5].float, forKey: "inputUnsharpMaskIntensity")
                filter.setValue(node.inputs[6].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDepthToDisparityNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Depth To Disparity",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDepthToDisparity")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDifferenceBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Difference Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDifferenceBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDiscBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Disc Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(8.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDiscBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[2].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[2].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDisintegrateWithMaskTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Disintegrate With Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Mask Image", type: .image, semantics: .image),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Shadow Radius", defaultValue: .float(8.0), semantics: .distance),
                    .init(name: "Shadow Density", defaultValue: .float(0.65), semantics: .default),
                    .init(name: "Shadow Offset", defaultValue: .vector2(.init(x: 0.0, y: -10.0)), semantics: .offset),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDisintegrateWithMaskTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputMaskImage")
                filter.setValue(node.inputs[3].float, forKey: "inputTime")
                filter.setValue(node.inputs[4].float, forKey: "inputShadowRadius")
                filter.setValue(node.inputs[5].float, forKey: "inputShadowDensity")
                filter.setValue(node.inputs[6].vector2.ciVector, forKey: "inputShadowOffset")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDisparityToDepthNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Disparity To Depth",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDisparityToDepth")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDisplacementDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Displacement Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Displacement Image", type: .image, semantics: .image),
                    .init(name: "Scale", defaultValue: .float(50.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDisplacementDistortion")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputDisplacementImage")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDissolveTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Dissolve",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDissolveTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(node.inputs[2].float, forKey: "inputTime")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDistanceGradientFromRedMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Distance Gradient From Red Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Maximum Distance", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDistanceGradientFromRedMask")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[2].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].float, forKey: "inputMaximumDistance")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[2].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDitherNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Dither",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Intensity", defaultValue: .float(0.1), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDither")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDivideBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Divide Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDivideBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDocumentEnhancerNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Document Enhancer",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Amount", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDocumentEnhancer")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDotScreenNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Dot Screen",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(6.0), semantics: .distance),
                    .init(name: "Sharpness", defaultValue: .float(0.7), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDotScreen")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIDrosteNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Droste",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Inset Point 0",
                        defaultValue: .vector2(.init(x: 200.0, y: 200.0)),
                        semantics: .position2
                    ),
                    .init(
                        name: "Inset Point 1",
                        defaultValue: .vector2(.init(x: 400.0, y: 400.0)),
                        semantics: .position2
                    ), .init(name: "Strands", defaultValue: .float(1.0), semantics: .count),
                    .init(name: "Periodicity", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Rotation", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Zoom", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDroste")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputInsetPoint0")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputInsetPoint1")
                filter.setValue(node.inputs[3].float, forKey: "inputStrands")
                filter.setValue(node.inputs[4].float, forKey: "inputPeriodicity")
                filter.setValue(node.inputs[5].float, forKey: "inputRotation")
                filter.setValue(node.inputs[6].float, forKey: "inputZoom")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIEdgePreserveUpsampleFilterNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Edge Preserve Upsample Filter",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Small Image", type: .image, semantics: .image),
                    .init(name: "Spatial Sigma", defaultValue: .float(3.0), semantics: .default),
                    .init(name: "Luma Sigma", defaultValue: .float(0.15), semantics: .default),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIEdgePreserveUpsampleFilter")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[4].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputSmallImage")
                filter.setValue(node.inputs[2].float, forKey: "inputSpatialSigma")
                filter.setValue(node.inputs[3].float, forKey: "inputLumaSigma")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[4].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIEdgesNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Edges",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Intensity", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIEdges")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIEdgeWorkNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Edge Work",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(3.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIEdgeWork")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIEightfoldReflectedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Eightfold Reflected Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIEightfoldReflectedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIExclusionBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Exclusion Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIExclusionBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIExposureAdjustNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Exposure Adjust",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "EV", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIExposureAdjust")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputEV")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIFalseColorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "False Color",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 0.3, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIFalseColor")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor1")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIFlashTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Flash",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Maximum Striation Radius", defaultValue: .float(2.58), semantics: .distance),
                    .init(name: "Striation Strength", defaultValue: .float(0.5), semantics: .default),
                    .init(name: "Striation Contrast", defaultValue: .float(1.375), semantics: .default),
                    .init(name: "Fade Threshold", defaultValue: .float(0.85), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIFlashTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(CIVector(cgRect: node.inputs[3].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[4].color4.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[5].float, forKey: "inputTime")
                filter.setValue(node.inputs[6].float, forKey: "inputMaxStriationRadius")
                filter.setValue(node.inputs[7].float, forKey: "inputStriationStrength")
                filter.setValue(node.inputs[8].float, forKey: "inputStriationContrast")
                filter.setValue(node.inputs[9].float, forKey: "inputFadeThreshold")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIFourfoldReflectedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Fourfold Reflected Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                    .init(name: "Acute Angle", defaultValue: .float(1.5707963267948966), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIFourfoldReflectedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputAcuteAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIFourfoldRotatedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Fourfold Rotated Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIFourfoldRotatedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIFourfoldTranslatedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Fourfold Translated Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                    .init(name: "Acute Angle", defaultValue: .float(1.5707963267948966), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIFourfoldTranslatedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputAcuteAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGaborGradientsNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Gabor Gradients",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGaborGradients")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGammaAdjustNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Gamma Adjust",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Power", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGammaAdjust")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputPower")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGaussianBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Gaussian Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGaussianBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[2].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[2].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGaussianGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Gaussian Gradient",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)),
                        semantics: .color
                    ), .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGaussianGradient")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor1")
                filter.setValue(node.inputs[3].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGlassDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Glass Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Texture", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Scale", defaultValue: .float(200.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGlassDistortion")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTexture")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[3].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGlassLozengeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Glass Lozenge",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Point 0", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Point 1", defaultValue: .vector2(.init(x: 350.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(100.0), semantics: .distance),
                    .init(name: "Refraction", defaultValue: .float(1.7), semantics: .default),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGlassLozenge")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[5].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputPoint0")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputPoint1")
                filter.setValue(node.inputs[3].float, forKey: "inputRadius")
                filter.setValue(node.inputs[4].float, forKey: "inputRefraction")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[5].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGlideReflectedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Glide Reflected Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGlideReflectedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGloomNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Gloom",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Intensity", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGloom")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIGuidedFilterNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Guided Filter",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "A larger image to use as a guide.", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(1.0), semantics: .distance),
                    .init(name: "Epsilon", defaultValue: .float(0.0001), semantics: .default),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIGuidedFilter")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[4].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputGuideImage")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputEpsilon")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[4].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHardLightBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hard Light Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHardLightBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHatchedScreenNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hatched Screen",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(6.0), semantics: .distance),
                    .init(name: "Sharpness", defaultValue: .float(0.7), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHatchedScreen")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHeightFieldFromMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Height Field From Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHeightFieldFromMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHexagonalPixellateNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hexagonal Pixelate",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Scale", defaultValue: .float(8.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHexagonalPixellate")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHighlightShadowAdjustNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Highlight and Shadow Adjust",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(0.0), semantics: .distance),
                    .init(name: "Shadow Amount", defaultValue: .float(0.0), semantics: .default),
                    .init(name: "Highlight Amount", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHighlightShadowAdjust")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputShadowAmount")
                filter.setValue(node.inputs[3].float, forKey: "inputHighlightAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHistogramDisplayFilterNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Histogram Display",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Height", defaultValue: .float(100.0), semantics: .default),
                    .init(name: "High Limit", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Low Limit", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHistogramDisplayFilter")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputHeight")
                filter.setValue(node.inputs[2].float, forKey: "inputHighLimit")
                filter.setValue(node.inputs[3].float, forKey: "inputLowLimit")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHoleDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hole Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(150.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHoleDistortion")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[3].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[3].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHueAdjustNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hue Adjust",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHueAdjust")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHueBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hue Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHueBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIHueSaturationValueGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Hue/Saturation/Value Gradient",
                inputs: [
                    .init(name: "Value", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Softness", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Dither", defaultValue: .float(1.0), semantics: .default),
                    .init(
                        name: "Color Space",
                        defaultValue: .colorSpace(.named("kCGColorSpaceSRGB")),
                        semantics: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIHueSaturationValueGradient")!
                filter.setValue(node.inputs[0].float, forKey: "inputValue")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputSoftness")
                filter.setValue(node.inputs[3].float, forKey: "inputDither")
                filter.setValue(node.inputs[4].colorSpace.cgColorSpace(), forKey: "inputColorSpace")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIKaleidoscopeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Kaleidoscope",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Count", defaultValue: .int(6), semantics: .count),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKaleidoscope")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].int, forKey: "inputCount")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIKeystoneCorrectionCombinedNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Combined Keystone Correction",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Focal Length", defaultValue: .float(28.0), semantics: .default),
                    .init(name: "Top Left", type: .vector2, semantics: .position2),
                    .init(name: "Top Right", type: .vector2, semantics: .position2),
                    .init(name: "Bottom Right", type: .vector2, semantics: .position2),
                    .init(name: "Bottom Left", type: .vector2, semantics: .position2),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKeystoneCorrectionCombined")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputFocalLength")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[5].vector2.ciVector, forKey: "inputBottomLeft")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIKeystoneCorrectionHorizontalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Horizontal Keystone Correction",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Focal Length", defaultValue: .float(28.0), semantics: .default),
                    .init(name: "Top Left", type: .vector2, semantics: .position2),
                    .init(name: "Top Right", type: .vector2, semantics: .position2),
                    .init(name: "Bottom Right", type: .vector2, semantics: .position2),
                    .init(name: "Bottom Left", type: .vector2, semantics: .position2),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKeystoneCorrectionHorizontal")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputFocalLength")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[5].vector2.ciVector, forKey: "inputBottomLeft")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIKeystoneCorrectionVerticalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vertical Keystone Correction",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Focal Length", defaultValue: .float(28.0), semantics: .default),
                    .init(name: "Top Left", type: .vector2, semantics: .position2),
                    .init(name: "Top Right", type: .vector2, semantics: .position2),
                    .init(name: "Bottom Right", type: .vector2, semantics: .position2),
                    .init(name: "Bottom Left", type: .vector2, semantics: .position2),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKeystoneCorrectionVertical")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputFocalLength")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[5].vector2.ciVector, forKey: "inputBottomLeft")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIKMeansNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "KMeans",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Means", type: .image, semantics: .image),
                    .init(name: "Count", defaultValue: .int(8), semantics: .count),
                    .init(name: "Passes", defaultValue: .int(5), semantics: .count),
                    .init(name: "Perceptual", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKMeans")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputMeans")
                filter.setValue(node.inputs[3].int, forKey: "inputCount")
                filter.setValue(node.inputs[4].int, forKey: "inputPasses")
                filter.setValue(node.inputs[5].bool, forKey: "inputPerceptual")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILabDeltaENode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Lab ∆E",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Image2", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILabDeltaE")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputImage2")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILanczosScaleTransformNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Lanczos Scale Transform",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Scale", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Aspect Ratio", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILanczosScaleTransform")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputScale")
                filter.setValue(node.inputs[2].float, forKey: "inputAspectRatio")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILenticularHaloGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Lenticular Halo",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Halo Radius", defaultValue: .float(70.0), semantics: .distance),
                    .init(name: "Halo Width", defaultValue: .float(87.0), semantics: .distance),
                    .init(name: "Halo Overlap", defaultValue: .float(0.77), semantics: .default),
                    .init(name: "Striation Strength", defaultValue: .float(0.5), semantics: .default),
                    .init(name: "Striation Contrast", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILenticularHaloGenerator")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[2].float, forKey: "inputHaloRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputHaloWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputHaloOverlap")
                filter.setValue(node.inputs[5].float, forKey: "inputStriationStrength")
                filter.setValue(node.inputs[6].float, forKey: "inputStriationContrast")
                filter.setValue(node.inputs[7].float, forKey: "inputTime")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILightenBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Lighten Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILightenBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILightTunnelNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Light Tunnel Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Rotation", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Radius", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILightTunnel")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRotation")
                filter.setValue(node.inputs[3].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILinearBurnBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Linear Burn Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILinearBurnBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILinearDodgeBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Linear Dodge Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILinearDodgeBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILinearGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Linear Gradient",
                inputs: [
                    .init(name: "Point 0", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .position2),
                    .init(name: "Point 1", defaultValue: .vector2(.init(x: 200.0, y: 200.0)), semantics: .position2),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILinearGradient")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputPoint0")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputPoint1")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[3].color4.ciColor, forKey: "inputColor1")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILinearLightBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Linear Light Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILinearLightBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILinearToSRGBToneCurveNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Linear to sRGB Tone Curve",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILinearToSRGBToneCurve")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILineOverlayNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Line Overlay",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "NR Noise Level", defaultValue: .float(0.07), semantics: .default),
                    .init(name: "NR Sharpness", defaultValue: .float(0.71), semantics: .default),
                    .init(name: "Edge Intensity", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Threshold", defaultValue: .float(0.1), semantics: .default),
                    .init(name: "Contrast", defaultValue: .float(50.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILineOverlay")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputNRNoiseLevel")
                filter.setValue(node.inputs[2].float, forKey: "inputNRSharpness")
                filter.setValue(node.inputs[3].float, forKey: "inputEdgeIntensity")
                filter.setValue(node.inputs[4].float, forKey: "inputThreshold")
                filter.setValue(node.inputs[5].float, forKey: "inputContrast")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILineScreenNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Line Screen",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(6.0), semantics: .distance),
                    .init(name: "Sharpness", defaultValue: .float(0.7), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILineScreen")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CILuminosityBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Luminosity Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CILuminosityBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMaskedVariableBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Masked Variable Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Mask", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(5.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMaskedVariableBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[3].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputMask")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[3].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMaskToAlphaNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Mask to Alpha",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMaskToAlpha")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMaximumComponentNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Maximum Component",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMaximumComponent")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMaximumCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Maximum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMaximumCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMaximumScaleTransformNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Maximum Scale Transform",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Scale", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Aspect Ratio", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMaximumScaleTransform")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputScale")
                filter.setValue(node.inputs[2].float, forKey: "inputAspectRatio")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMedianFilterNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Median",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMedianFilter")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMinimumComponentNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Minimum Component",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMinimumComponent")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMinimumCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Minimum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMinimumCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMixNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Mix",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                    .init(name: "Amount", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMix")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                filter.setValue(node.inputs[2].float, forKey: "inputAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIModTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Mod",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Angle", defaultValue: .float(2.0), semantics: .angle),
                    .init(name: "Radius", defaultValue: .float(150.0), semantics: .distance),
                    .init(name: "Compression", defaultValue: .float(300.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIModTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[3].float, forKey: "inputTime")
                filter.setValue(node.inputs[4].float, forKey: "inputAngle")
                filter.setValue(node.inputs[5].float, forKey: "inputRadius")
                filter.setValue(node.inputs[6].float, forKey: "inputCompression")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMorphologyGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Morphology Gradient",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(5.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMorphologyGradient")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMorphologyMaximumNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Morphology Maximum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(0.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMorphologyMaximum")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMorphologyMinimumNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Morphology Minimum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(0.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMorphologyMinimum")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMorphologyRectangleMaximumNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Morphology Rectangle Maximum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Width", defaultValue: .int(5), semantics: .integer),
                    .init(name: "Height", defaultValue: .int(5), semantics: .integer),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMorphologyRectangleMaximum")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].int, forKey: "inputWidth")
                filter.setValue(node.inputs[2].int, forKey: "inputHeight")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMorphologyRectangleMinimumNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Morphology Rectangle Minimum",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Width", defaultValue: .int(5), semantics: .integer),
                    .init(name: "Height", defaultValue: .int(5), semantics: .integer),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMorphologyRectangleMinimum")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].int, forKey: "inputWidth")
                filter.setValue(node.inputs[2].int, forKey: "inputHeight")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMotionBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Motion Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(20.0), semantics: .distance),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMotionBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[3].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[3].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMultiplyBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Multiply Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMultiplyBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIMultiplyCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Multiply",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIMultiplyCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CINinePartStretchedNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Nine Part Stretched",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Breakpoint0", defaultValue: .vector2(.init(x: 50.0, y: 50.0)), semantics: .position2),
                    .init(
                        name: "Breakpoint1",
                        defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                        semantics: .position2
                    ),
                    .init(name: "Grow Amount", defaultValue: .vector2(.init(x: 100.0, y: 100.0)), semantics: .offset),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CINinePartStretched")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputBreakpoint0")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputBreakpoint1")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputGrowAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CINinePartTiledNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Nine Part Tiled",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Breakpoint0", defaultValue: .vector2(.init(x: 50.0, y: 50.0)), semantics: .position2),
                    .init(
                        name: "Breakpoint1",
                        defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                        semantics: .position2
                    ),
                    .init(name: "Grow Amount", defaultValue: .vector2(.init(x: 100.0, y: 100.0)), semantics: .offset),
                    .init(name: "Flip Y Tiles", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CINinePartTiled")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputBreakpoint0")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputBreakpoint1")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputGrowAmount")
                filter.setValue(node.inputs[4].bool, forKey: "inputFlipYTiles")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CINoiseReductionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Noise Reduction",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Noise Level", defaultValue: .float(0.02), semantics: .default),
                    .init(name: "Sharpness", defaultValue: .float(0.4), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CINoiseReduction")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputNoiseLevel")
                filter.setValue(node.inputs[2].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIOpTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Op Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Scale", defaultValue: .float(2.8), semantics: .default),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(65.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIOpTile")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                filter.setValue(node.inputs[4].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIOverlayBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Overlay Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIOverlayBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPageCurlTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Page Curl",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Backside Image", type: .image, semantics: .image),
                    .init(name: "Shading Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Radius", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPageCurlTransition")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputBacksideImage")
                filter.setValue(await context.getImage(node.inputs[3].image), forKey: "inputShadingImage")
                filter.setValue(CIVector(cgRect: node.inputs[4].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[5].float, forKey: "inputTime")
                filter.setValue(node.inputs[6].float, forKey: "inputAngle")
                filter.setValue(node.inputs[7].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPageCurlWithShadowTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Page Curl With Shadow",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Backside Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Radius", defaultValue: .float(100.0), semantics: .distance),
                    .init(name: "Shadow Size", defaultValue: .float(0.5), semantics: .distance),
                    .init(name: "Shadow Amount", defaultValue: .float(0.7), semantics: .distance),
                    .init(name: "Shadow Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPageCurlWithShadowTransition")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputBacksideImage")
                filter.setValue(CIVector(cgRect: node.inputs[3].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[4].float, forKey: "inputTime")
                filter.setValue(node.inputs[5].float, forKey: "inputAngle")
                filter.setValue(node.inputs[6].float, forKey: "inputRadius")
                filter.setValue(node.inputs[7].float, forKey: "inputShadowSize")
                filter.setValue(node.inputs[8].float, forKey: "inputShadowAmount")
                filter.setValue(CIVector(cgRect: node.inputs[9].rect), forKey: "inputShadowExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPalettizeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Palettize",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Palette Image", type: .image, semantics: .image),
                    .init(name: "Perceptual", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPalettize")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputPaletteImage")
                filter.setValue(node.inputs[2].bool, forKey: "inputPerceptual")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIParallelogramTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Parallelogram Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Acute Angle", defaultValue: .float(1.5707963267948966), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIParallelogramTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputAcuteAngle")
                filter.setValue(node.inputs[4].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPersonSegmentationNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Person Segmentation",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Quality Level", defaultValue: .int(0), semantics: .integer),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPersonSegmentation")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].int, forKey: "inputQualityLevel")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPerspectiveCorrectionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Perspective Correction",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Top Left", defaultValue: .vector2(.init(x: 118.0, y: 484.0)), semantics: .position2),
                    .init(name: "Top Right", defaultValue: .vector2(.init(x: 646.0, y: 507.0)), semantics: .position2),
                    .init(
                        name: "Bottom Right",
                        defaultValue: .vector2(.init(x: 548.0, y: 140.0)),
                        semantics: .position2
                    ),
                    .init(
                        name: "Bottom Left",
                        defaultValue: .vector2(.init(x: 155.0, y: 153.0)),
                        semantics: .position2
                    ), .init(name: "Crop", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPerspectiveCorrection")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomLeft")
                filter.setValue(node.inputs[5].bool, forKey: "inputCrop")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPerspectiveRotateNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Perspective Rotate",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Focal Length", defaultValue: .float(28.0), semantics: .default),
                    .init(name: "Pitch", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Yaw", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Roll", defaultValue: .float(0.0), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPerspectiveRotate")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputFocalLength")
                filter.setValue(node.inputs[2].float, forKey: "inputPitch")
                filter.setValue(node.inputs[3].float, forKey: "inputYaw")
                filter.setValue(node.inputs[4].float, forKey: "inputRoll")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPerspectiveTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Perspective Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Top Left", defaultValue: .vector2(.init(x: 118.0, y: 484.0)), semantics: .position2),
                    .init(name: "Top Right", defaultValue: .vector2(.init(x: 646.0, y: 507.0)), semantics: .position2),
                    .init(
                        name: "Bottom Right",
                        defaultValue: .vector2(.init(x: 548.0, y: 140.0)),
                        semantics: .position2
                    ),
                    .init(
                        name: "Bottom Left",
                        defaultValue: .vector2(.init(x: 155.0, y: 153.0)),
                        semantics: .position2
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPerspectiveTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomLeft")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPerspectiveTransformNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Perspective Transform",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Top Left", defaultValue: .vector2(.init(x: 118.0, y: 484.0)), semantics: .position2),
                    .init(name: "Top Right", defaultValue: .vector2(.init(x: 646.0, y: 507.0)), semantics: .position2),
                    .init(
                        name: "Bottom Right",
                        defaultValue: .vector2(.init(x: 548.0, y: 140.0)),
                        semantics: .position2
                    ),
                    .init(
                        name: "Bottom Left",
                        defaultValue: .vector2(.init(x: 155.0, y: 153.0)),
                        semantics: .position2
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPerspectiveTransform")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomLeft")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPerspectiveTransformWithExtentNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Perspective Transform with Extent",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Top Left", defaultValue: .vector2(.init(x: 118.0, y: 484.0)), semantics: .position2),
                    .init(name: "Top Right", defaultValue: .vector2(.init(x: 646.0, y: 507.0)), semantics: .position2),
                    .init(
                        name: "Bottom Right",
                        defaultValue: .vector2(.init(x: 548.0, y: 140.0)),
                        semantics: .position2
                    ),
                    .init(
                        name: "Bottom Left",
                        defaultValue: .vector2(.init(x: 155.0, y: 153.0)),
                        semantics: .position2
                    ), .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPerspectiveTransformWithExtent")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[6].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTopLeft")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputTopRight")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputBottomRight")
                filter.setValue(node.inputs[5].vector2.ciVector, forKey: "inputBottomLeft")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[6].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectChromeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Chrome",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectChrome")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectFadeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Fade",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectFade")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectInstantNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Instant",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectInstant")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectMonoNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Mono",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectMono")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectNoirNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Noir",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectNoir")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectProcessNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Process",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectProcess")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectTonalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Tonal",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectTonal")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPhotoEffectTransferNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Photo Effect Transfer",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPhotoEffectTransfer")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPinchDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Pinch Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Scale", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPinchDistortion")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPinLightBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Pin Light Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPinLightBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPixellateNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Pixelate",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Scale", defaultValue: .float(8.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPixellate")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIPointillizeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Pointillize",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(20.0), semantics: .distance),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPointillize")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIQRCodeGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "QR Code Generator",
                inputs: [
                    .init(name: "Message", type: .data, semantics: .default),
                    .init(name: "Correction Level", defaultValue: .string("M"), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIQRCodeGenerator")!
                filter.setValue(node.inputs[0].data, forKey: "inputMessage")
                filter.setValue(node.inputs[1].string, forKey: "inputCorrectionLevel")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRadialGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Radial Gradient",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius 1", defaultValue: .float(5.0), semantics: .distance),
                    .init(name: "Radius 2", defaultValue: .float(100.0), semantics: .distance),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRadialGradient")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius0")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius1")
                filter.setValue(node.inputs[3].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[4].color4.ciColor, forKey: "inputColor1")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRandomGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Random Generator",
                inputs: [],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRandomGenerator")!

                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRippleTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Ripple",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Shading Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                    .init(name: "Scale", defaultValue: .float(50.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRippleTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(await context.getImage(node.inputs[2].image), forKey: "inputShadingImage")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(CIVector(cgRect: node.inputs[4].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[5].float, forKey: "inputTime")
                filter.setValue(node.inputs[6].float, forKey: "inputWidth")
                filter.setValue(node.inputs[7].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRoundedQRCodeGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Rounded QR Code Generator",
                inputs: [
                    .init(name: "Message", type: .data, semantics: .default),
                    .init(name: "Correction Level", defaultValue: .string("M"), semantics: .default),
                    .init(name: "Scale", defaultValue: .float(16.0), semantics: .default),
                    .init(name: "Rounded Markers", defaultValue: .int(1), semantics: .integer),
                    .init(name: "Rounded Data", defaultValue: .bool(true), semantics: .boolean),
                    .init(name: "Center Space Size", defaultValue: .float(0.25), semantics: .default),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRoundedQRCodeGenerator")!
                filter.setValue(node.inputs[0].data, forKey: "inputMessage")
                filter.setValue(node.inputs[1].string, forKey: "inputCorrectionLevel")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                filter.setValue(node.inputs[3].int, forKey: "inputRoundedMarkers")
                filter.setValue(node.inputs[4].bool, forKey: "inputRoundedData")
                filter.setValue(node.inputs[5].float, forKey: "inputCenterSpaceSize")
                filter.setValue(node.inputs[6].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[7].color4.ciColor, forKey: "inputColor1")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRoundedRectangleGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Rounded Rectangle Generator",
                inputs: [
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Smoothness", defaultValue: .float(0.0), semantics: .distance),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRoundedRectangleGenerator")!
                filter.setValue(CIVector(cgRect: node.inputs[0].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputSmoothness")
                filter.setValue(node.inputs[3].color4.ciColor, forKey: "inputColor")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRoundedRectangleStrokeGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Rounded Rectangle Stroke Generator",
                inputs: [
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(name: "Radius", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Smoothness", defaultValue: .float(0.0), semantics: .distance),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Width", defaultValue: .float(10.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRoundedRectangleStrokeGenerator")!
                filter.setValue(CIVector(cgRect: node.inputs[0].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputSmoothness")
                filter.setValue(node.inputs[3].color4.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[4].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIRowAverageNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Row Average",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIRowAverage")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(cgRect: node.inputs[1].rect), forKey: "inputExtent")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISaliencyMapFilterNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Saliency Map Filter",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISaliencyMapFilter")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISampleNearestNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sample Nearest",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISampleNearest")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISaturationBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Saturation Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISaturationBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIScreenBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Screen Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIScreenBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISepiaToneNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sepia Tone",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Intensity", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISepiaTone")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIShadedMaterialNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Shaded Material",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Shading Image", type: .image, semantics: .image),
                    .init(name: "Scale", defaultValue: .float(10.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIShadedMaterial")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputShadingImage")
                filter.setValue(node.inputs[2].float, forKey: "inputScale")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISharpenLuminanceNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sharpen Luminance",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Sharpness", defaultValue: .float(0.4), semantics: .default),
                    .init(name: "Radius", defaultValue: .float(1.69), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISharpenLuminance")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputSharpness")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISignedDistanceGradientFromRedMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Signed Distance Gradient From Red Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Maximum Distance", defaultValue: .float(10.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISignedDistanceGradientFromRedMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputMaximumDistance")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISixfoldReflectedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sixfold Reflected Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISixfoldReflectedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISixfoldRotatedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sixfold Rotated Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISixfoldRotatedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISmoothLinearGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Smooth Linear Gradient",
                inputs: [
                    .init(name: "Point 0", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .position2),
                    .init(name: "Point 1", defaultValue: .vector2(.init(x: 200.0, y: 200.0)), semantics: .position2),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISmoothLinearGradient")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputPoint0")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputPoint1")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[3].color4.ciColor, forKey: "inputColor1")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISobelGradientsNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sobel Gradients",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISobelGradients")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISoftLightBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Soft Light Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISoftLightBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISourceAtopCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Source Atop",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISourceAtopCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISourceInCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Source In",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISourceInCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISourceOutCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Source Out",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISourceOutCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISourceOverCompositingNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Source Over",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISourceOverCompositing")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISpotColorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Spot Color",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Center Color 1",
                        defaultValue: .color4(.init(red: 0.0784, green: 0.0627, blue: 0.0706, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Replacement Color 1",
                        defaultValue: .color4(.init(red: 0.4392, green: 0.1922, blue: 0.1961, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Closeness 1", defaultValue: .float(0.22), semantics: .default),
                    .init(name: "Contrast 1", defaultValue: .float(0.98), semantics: .default),
                    .init(
                        name: "Center Color 2",
                        defaultValue: .color4(.init(red: 0.5255, green: 0.3059, blue: 0.3451, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Replacement Color 2",
                        defaultValue: .color4(.init(red: 0.9137, green: 0.5608, blue: 0.5059, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Closeness 2", defaultValue: .float(0.15), semantics: .default),
                    .init(name: "Contrast 2", defaultValue: .float(0.98), semantics: .default),
                    .init(
                        name: "Center Color 3",
                        defaultValue: .color4(.init(red: 0.9216, green: 0.4549, blue: 0.3333, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Replacement Color 3",
                        defaultValue: .color4(.init(red: 0.9098, green: 0.7529, blue: 0.6078, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Closeness 3", defaultValue: .float(0.5), semantics: .default),
                    .init(name: "Contrast 3", defaultValue: .float(0.99), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISpotColor")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputCenterColor1")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputReplacementColor1")
                filter.setValue(node.inputs[3].float, forKey: "inputCloseness1")
                filter.setValue(node.inputs[4].float, forKey: "inputContrast1")
                filter.setValue(node.inputs[5].color4.ciColor, forKey: "inputCenterColor2")
                filter.setValue(node.inputs[6].color4.ciColor, forKey: "inputReplacementColor2")
                filter.setValue(node.inputs[7].float, forKey: "inputCloseness2")
                filter.setValue(node.inputs[8].float, forKey: "inputContrast2")
                filter.setValue(node.inputs[9].color4.ciColor, forKey: "inputCenterColor3")
                filter.setValue(node.inputs[10].color4.ciColor, forKey: "inputReplacementColor3")
                filter.setValue(node.inputs[11].float, forKey: "inputCloseness3")
                filter.setValue(node.inputs[12].float, forKey: "inputContrast3")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISpotLightNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Spot Light",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Light Position",
                        defaultValue: .vector3(.init(x: 400.0, y: 600.0, z: 150.0)),
                        semantics: .position3
                    ),
                    .init(
                        name: "Light Points At",
                        defaultValue: .vector3(.init(x: 200.0, y: 200.0, z: 0.0)),
                        semantics: .position3
                    ), .init(name: "Brightness", defaultValue: .float(3.0), semantics: .distance),
                    .init(name: "Concentration", defaultValue: .float(0.1), semantics: .default),
                    .init(
                        name: "Color",
                        defaultValue: .color3(.init(red: 1.0, green: 1.0, blue: 1.0)),
                        semantics: .opaqueColor
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISpotLight")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector3.ciVector, forKey: "inputLightPosition")
                filter.setValue(node.inputs[2].vector3.ciVector, forKey: "inputLightPointsAt")
                filter.setValue(node.inputs[3].float, forKey: "inputBrightness")
                filter.setValue(node.inputs[4].float, forKey: "inputConcentration")
                filter.setValue(node.inputs[5].color3.ciColor, forKey: "inputColor")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISRGBToneCurveToLinearNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "sRGB Tone Curve to Linear",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISRGBToneCurveToLinear")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIStarShineGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Star Shine",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Radius", defaultValue: .float(50.0), semantics: .distance),
                    .init(name: "Cross Scale", defaultValue: .float(15.0), semantics: .default),
                    .init(name: "Cross Angle", defaultValue: .float(0.6), semantics: .angle),
                    .init(name: "Cross Opacity", defaultValue: .float(-2.0), semantics: .default),
                    .init(name: "Cross Width", defaultValue: .float(2.5), semantics: .distance),
                    .init(name: "Epsilon", defaultValue: .float(-2.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIStarShineGenerator")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputCrossScale")
                filter.setValue(node.inputs[4].float, forKey: "inputCrossAngle")
                filter.setValue(node.inputs[5].float, forKey: "inputCrossOpacity")
                filter.setValue(node.inputs[6].float, forKey: "inputCrossWidth")
                filter.setValue(node.inputs[7].float, forKey: "inputEpsilon")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIStraightenFilterNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Straighten",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIStraightenFilter")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIStretchCropNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Stretch Crop",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Size", defaultValue: .vector2(.init(x: 1280.0, y: 720.0)), semantics: .position2),
                    .init(name: "Crop Amount", defaultValue: .float(0.25), semantics: .default),
                    .init(name: "Center Stretch Amount", defaultValue: .float(0.25), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIStretchCrop")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputSize")
                filter.setValue(node.inputs[2].float, forKey: "inputCropAmount")
                filter.setValue(node.inputs[3].float, forKey: "inputCenterStretchAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIStripesGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Stripes",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Width", defaultValue: .float(80.0), semantics: .distance),
                    .init(name: "Sharpness", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIStripesGenerator")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor0")
                filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor1")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputSharpness")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISubtractBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Subtract Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISubtractBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISunbeamsGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Sunbeams",
                inputs: [
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)),
                        semantics: .color
                    ), .init(name: "Sun Radius", defaultValue: .float(40.0), semantics: .distance),
                    .init(name: "Maximum Striation Radius", defaultValue: .float(2.58), semantics: .distance),
                    .init(name: "Striation Strength", defaultValue: .float(0.5), semantics: .default),
                    .init(name: "Striation Contrast", defaultValue: .float(1.375), semantics: .default),
                    .init(name: "Time", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISunbeamsGenerator")!
                filter.setValue(node.inputs[0].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[2].float, forKey: "inputSunRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputMaxStriationRadius")
                filter.setValue(node.inputs[4].float, forKey: "inputStriationStrength")
                filter.setValue(node.inputs[5].float, forKey: "inputStriationContrast")
                filter.setValue(node.inputs[6].float, forKey: "inputTime")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CISwipeTransitionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Swipe",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Target Image", type: .image, semantics: .image),
                    .init(name: "Extent", type: .rect, semantics: .rectangle),
                    .init(
                        name: "Color",
                        defaultValue: .color3(.init(red: 1.0, green: 1.0, blue: 1.0)),
                        semantics: .opaqueColor
                    ), .init(name: "Time", defaultValue: .float(0.0), semantics: .time),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Opacity", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CISwipeTransition")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputTargetImage")
                filter.setValue(CIVector(cgRect: node.inputs[2].rect), forKey: "inputExtent")
                filter.setValue(node.inputs[3].color3.ciColor, forKey: "inputColor")
                filter.setValue(node.inputs[4].float, forKey: "inputTime")
                filter.setValue(node.inputs[5].float, forKey: "inputAngle")
                filter.setValue(node.inputs[6].float, forKey: "inputWidth")
                filter.setValue(node.inputs[7].float, forKey: "inputOpacity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITemperatureAndTintNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Temperature and Tint",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Neutral", defaultValue: .vector2(.init(x: 6500.0, y: 0.0)), semantics: .offset),
                    .init(name: "Target Neutral", defaultValue: .vector2(.init(x: 6500.0, y: 0.0)), semantics: .offset),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITemperatureAndTint")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputNeutral")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputTargetNeutral")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITextImageGeneratorNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Text Image Generator",
                inputs: [
                    .init(name: "Text", type: .string, semantics: .default),
                    .init(name: "Font Name", defaultValue: .string("HelveticaNeue"), semantics: .default),
                    .init(name: "Font Size", defaultValue: .float(12.0), semantics: .default),
                    .init(name: "Scale Factor", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Padding", defaultValue: .int(0), semantics: .integer),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITextImageGenerator")!
                filter.setValue(node.inputs[0].string, forKey: "inputText")
                filter.setValue(node.inputs[1].string, forKey: "inputFontName")
                filter.setValue(node.inputs[2].float, forKey: "inputFontSize")
                filter.setValue(node.inputs[3].float, forKey: "inputScaleFactor")
                filter.setValue(node.inputs[4].int, forKey: "inputPadding")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIThermalNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Thermal",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIThermal")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIToneCurveNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Tone Curve",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Point 0", defaultValue: .vector2(.init(x: 0.0, y: 0.0)), semantics: .offset),
                    .init(name: "Point 1", defaultValue: .vector2(.init(x: 0.25, y: 0.25)), semantics: .offset),
                    .init(name: "Point 2", defaultValue: .vector2(.init(x: 0.5, y: 0.5)), semantics: .offset),
                    .init(name: "Point 3", defaultValue: .vector2(.init(x: 0.75, y: 0.75)), semantics: .offset),
                    .init(name: "Point 4", defaultValue: .vector2(.init(x: 1.0, y: 1.0)), semantics: .offset),
                    .init(name: "Extrapolate", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIToneCurve")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputPoint0")
                filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputPoint1")
                filter.setValue(node.inputs[3].vector2.ciVector, forKey: "inputPoint2")
                filter.setValue(node.inputs[4].vector2.ciVector, forKey: "inputPoint3")
                filter.setValue(node.inputs[5].vector2.ciVector, forKey: "inputPoint4")
                filter.setValue(node.inputs[6].bool, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIToneMapHeadroomNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Tone Map Headroom",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Source Headroom", type: .float, semantics: .default),
                    .init(name: "Target Headroom", defaultValue: .float(1.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIToneMapHeadroom")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputSourceHeadroom")
                filter.setValue(node.inputs[2].float, forKey: "inputTargetHeadroom")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITorusLensDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Torus Lens Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(160.0), semantics: .distance),
                    .init(name: "Width", defaultValue: .float(80.0), semantics: .distance),
                    .init(name: "Refraction", defaultValue: .float(1.7), semantics: .default),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITorusLensDistortion")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[5].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                filter.setValue(node.inputs[4].float, forKey: "inputRefraction")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[5].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITriangleKaleidoscopeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Triangle Kaleidoscope",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Point", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Size", defaultValue: .float(700.0), semantics: .default),
                    .init(name: "Rotation", defaultValue: .float(5.924285296593801), semantics: .angle),
                    .init(name: "Decay", defaultValue: .float(0.85), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITriangleKaleidoscope")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputPoint")
                filter.setValue(node.inputs[2].float, forKey: "inputSize")
                filter.setValue(node.inputs[3].float, forKey: "inputRotation")
                filter.setValue(node.inputs[4].float, forKey: "inputDecay")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITriangleTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Triangle Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITriangleTile")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITwelvefoldReflectedTileNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Twelvefold Reflected Tile",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Angle", defaultValue: .float(0.0), semantics: .angle),
                    .init(name: "Width", defaultValue: .float(100.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITwelvefoldReflectedTile")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CITwirlDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Twirl Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Angle", defaultValue: .float(3.141592653589793), semantics: .angle),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITwirlDistortion")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[4].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[4].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIUnsharpMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Unsharp Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Radius", defaultValue: .float(2.5), semantics: .distance),
                    .init(name: "Intensity", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIUnsharpMask")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputRadius")
                filter.setValue(node.inputs[2].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIVibranceNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vibrance",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Amount", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIVibrance")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIVignetteNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vignette",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Intensity", defaultValue: .float(0.0), semantics: .default),
                    .init(name: "Radius", defaultValue: .float(1.0), semantics: .distance),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIVignette")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputIntensity")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIVignetteEffectNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vignette Effect",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(150.0), semantics: .distance),
                    .init(name: "Intensity", defaultValue: .float(1.0), semantics: .default),
                    .init(name: "Falloff", defaultValue: .float(0.5), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIVignetteEffect")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputIntensity")
                filter.setValue(node.inputs[4].float, forKey: "inputFalloff")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIVividLightBlendModeNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vivid Light Blend Mode",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Background Image", type: .image, semantics: .image),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIVividLightBlendMode")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(await context.getImage(node.inputs[1].image), forKey: "inputBackgroundImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIVortexDistortionNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Vortex Distortion",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Radius", defaultValue: .float(300.0), semantics: .distance),
                    .init(name: "Angle", defaultValue: .float(56.548667764616276), semantics: .angle),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIVortexDistortion")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[4].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputRadius")
                filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[4].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIWhitePointAdjustNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "White Point Adjust",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIWhitePointAdjust")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].color4.ciColor, forKey: "inputColor")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIXRayNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "X-Ray",
                inputs: [.init(name: "Image", type: .image, semantics: .image)],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIXRay")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIZoomBlurNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Zoom Blur",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150.0, y: 150.0)), semantics: .position2),
                    .init(name: "Amount", defaultValue: .float(20.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIZoomBlur")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                if node.inputs[3].bool {
                    filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                } else {
                    filter.setValue(inputImage, forKey: "inputImage")
                }
                filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                filter.setValue(node.inputs[2].float, forKey: "inputAmount")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    if node.inputs[3].bool {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    }
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }
}
