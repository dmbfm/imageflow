import Backend

extension NodeKind {
    public var docSlug: (String, String)? {
        switch self {
        // Input
        case .valueNode(.affineTransform): ("input", "affine-transform")
        case .valueNode(.bool): ("input", "boolean")
        case .valueNode(.color4): ("input", "color")
        case .valueNode(.float): ("input", "float")
        case .valueNode(.gradientData): ("input", "gradient-data")
        case .valueNode(.image): ("input", "image")
        case .valueNode(.int): ("input", "integer")
        case .valueNode(.matrix2x2): ("input", "matrix2x2")
        case .valueNode(.matrix3x3): ("input", "matrix3x3")
        case .valueNode(.matrix5x5): ("input", "matrix5x5")
        case .valueNode(.matrix7x7): ("input", "matrix7x7")
        case .valueNode(.rect): ("input", "rectangle")
        case .valueNode(.string): ("input", "string")
        case .valueNode(.textStyle): ("input", "text-style")
        case .valueNode(.vector2): ("input", "vector2")
        case .valueNode(.vector3): ("input", "vector3")
        case .valueNode(.vector4): ("input", "vector4")
        // Image
        case .splitValue(.imageChannels): ("image", "channel-masks")
        case .combineValue(.imageRGB): ("image", "combine-rgb-masks")
        case .combineValue(.imageRGBA): ("image", "combine-rgba-masks")
        case .splitValue(.imageOrigin): ("image", "image-origin")
        case .splitValue(.imageRect): ("image", "image-rect")
        case .splitValue(.imageSize): ("image", "image-size")
        // Blur
        case .coreImageFilterNode(.blur(.CIBokehBlur)): ("blur", "bokeh")
        case .coreImageFilterNode(.blur(.CIBoxBlur)): ("blur", "box")
        case .coreImageFilterNode(.blur(.CIDiscBlur)): ("blur", "disc")
        case .coreImageFilterNode(.blur(.CIGaussianBlur)): ("blur", "gaussian")
        case .coreImageFilterNode(.blur(.CIMaskedVariableBlur)): ("blur", "masked-variable-blur")
        case .coreImageFilterNode(.blur(.CIMedianFilter)): ("blur", "median")
        case .coreImageFilterNode(.blur(.CIMotionBlur)): ("blur", "motion")
        case .coreImageFilterNode(.blur(.CINoiseReduction)): ("blur", "noise-reduction")
        case .coreImageFilterNode(.blur(.CIZoomBlur)): ("blur", "zoom")
        // Math Operations
        case .math(.addNode(_)): ("math-operations", "add")
        case .math(.divNode(_)): ("math-operations", "divide")
        case .math(.mulNode(_)): ("math-operations", "multiply")
        case .math(.subNode(_)): ("math-operations", "subtract")
        default: nil
        }
    }
}
