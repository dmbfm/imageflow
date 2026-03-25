import CoreImage
import CoreImage.CIFilterBuiltins
import Values

public struct FilterInfoCollection: Sendable, Hashable, Codable {

    public var filters: [FilterInfo] = []

    static let blacklist: [String] =
        [
            "CIDepthBlurEffect",
            "CICameraCalibrationLensCorrection",
            "CICoreMLModelFilter",
            "CIBarcodeGenerator",
            "CIMeshGenerator",
            "CIAztecCodeGenerator",
            "CICode128BarcodeGenerator",
            "CIPDF417BarcodeGenerator",
            "CISystemToneMap",
            "CIColorCube",
            "CIColorCubesMixedWithMask",
            "CIColorCubeWithColorSpace",
            "CIColorCrossPolynomial",
            "CIPaletteCentroid",
            "CIPersonSegmentation",
            "CISaliencyMap",
            "CIDisintegrateWithMaskTransition",
            "CIAccordionFoldTransition",
        ]

    static let overrides: [Override] = [
        .init(name: "CIAccordionFoldTransition", filterOverride: .input("inputNumberOfFolds", .type(.count))),
        .init(name: "CIAccordionFoldTransition", filterOverride: .input("inputNumberOfFolds", .valueType(.int))),
        .init(name: "CIAccordionFoldTransition", filterOverride: .input("inputNumberOfFolds", .defaultValue(.int(3)))),
        .init(
            name: "CIBlurredRectangleGenerator",
            filterOverride: .input(
                "inputExtent",
                .defaultValue(.rect(.init(x: 0, y: 0, width: 256, height: 256)))
            )
        ),
        .init(
            name: "CIColorClamp",
            filterOverride: .input("inputMinComponents", .defaultValue(.vector4(.init(x: 0, y: 0, z: 0, w: 0))))
        ),
        .init(
            name: "CIColorClamp",
            filterOverride: .input("inputMaxComponents", .defaultValue(.vector4(.init(x: 1, y: 1, z: 1, w: 1))))
        ),
        .init(
            name: "CIColorMatrix",
            filterOverride: .inputs(
                [
                    ("inputRVector", .defaultValue(.vector4(.init(x: 1, y: 0, z: 0, w: 0)))),
                    ("inputGVector", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                    ("inputBVector", .defaultValue(.vector4(.init(x: 0, y: 0, z: 1, w: 0)))),
                    ("inputAVector", .defaultValue(.vector4(.init(x: 0, y: 0, z: 0, w: 1)))),
                    ("inputBiasVector", .defaultValue(.vector4(.init(x: 1, y: 0, z: 0, w: 0)))),
                ])
        ),
        .init(
            name: "CIColorPolynomial",
            filterOverride: .inputs(
                [
                    ("inputRedCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                    ("inputGreenCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                    ("inputBlueCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                    ("inputAlphaCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                ])
        ),
        .init(
            name: "CIColorCrossPolynomial",
            filterOverride: .inputs(
                [
                    ("inputRedCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                    ("inputGreenCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                    ("inputBlueCoefficients", .defaultValue(.vector4(.init(x: 0, y: 1, z: 0, w: 0)))),
                ])
        ),
        .init(
            name: "CIDroste",
            filterOverride: .inputs(
                [
                    ("inputStrands", .defaultValue(.int(1))),
                    ("inputStrands", .type(.count)),
                ]
            )
        ),
        .init(
            name: "CICrop",
            filterOverride: .input("inputRectangle", .defaultValue(.rect(.init(x: 0, y: 0, width: 100, height: 100))))
        ),
    ]

    static let fallbackCategories: [String: String] = [
        "CILineOverlay": kCICategoryStylize,
        "CISpotColor": kCICategoryStylize,
    ]

    public init() {
        var filters = [FilterInfo]()

        for filterName in CIFilter.filterNames(inCategory: nil) {
            if Self.blacklist.contains(filterName) { continue }

            guard let filter = CIFilter(name: filterName) else {
                continue
            }

            guard
                let category = (filter.attributes[kCIAttributeFilterCategories] as? [String])?.first.map({
                    guard let result = FilterCategory(rawValue: $0) else {

                        if let fb = Self.fallbackCategories[filterName] {
                            return FilterCategory(rawValue: fb)!
                        }

                        fatalError("\(filterName) - \($0)")
                    }

                    return result
                })
            else {
                continue
            }

            var info = FilterInfo(
                name: filterName,
                displayName: CIFilter.localizedName(forFilterName: filterName) ?? filterName,  //(filter.attributes[kCIAttributeDisplayName] as? String) ?? "",
                category: category,
                description: CIFilter.localizedDescription(forFilterName: filterName),
                docs: filter.attributes[kCIAttributeReferenceDocumentation] as? URL,
                availableIOS: filter.attributes[kCIAttributeFilterAvailable_iOS] as? String,
                availableMacOS: filter.attributes[kCIAttributeFilterAvailable_Mac] as? String,
                inputs: []
            )

            for inputKey in filter.inputKeys {
                let attrs = filter.attributes[inputKey] as! [String: Any?]

                let className = InputClassName(rawValue: attrs[kCIAttributeClass]! as! String)!
                let type: InputType? = (attrs[kCIAttributeType] as? String).flatMap { value in
                    .init(rawValue: value)
                }
                let valueType = valueType(className, type) ?? .float

                info.inputs.append(
                    FilterInput(
                        name: inputKey,
                        displayName: attrs[kCIAttributeDisplayName] as? String,
                        description: attrs[kCIAttributeDescription] as? String,
                        className: className,
                        type: type,
                        min: (attrs[kCIAttributeMin] as? NSNumber)?.doubleValue,
                        max: (attrs[kCIAttributeMax] as? NSNumber)?.doubleValue,
                        sliderMin: (attrs[kCIAttributeSliderMin] as? NSNumber)?.doubleValue,
                        sliderMax: (attrs[kCIAttributeSliderMax] as? NSNumber)?.doubleValue,
                        valueType: valueType,
                        defaultValue: defaultValue(valueType, attrs[kCIAttributeDefault]),
                        identity: defaultValue(valueType, attrs[kCIAttributeIdentity])
                    )
                )
            }

            filters.append(info)
        }

        self.filters = filters
        for override in Self.overrides {
            self.apply(override: override)
        }

        self.apply(heuristics: .countIsCount)
        self.apply(heuristics: .radiusIsDistance)
    }

    mutating func apply(override: Override) {
        guard let index = self.filters.firstIndex(where: { $0.name == override.name }) else { return }
        self.filters[index] = self.filters[index].applying(override: override.filterOverride)
    }

    mutating func apply(heuristics: Heuristics) {
        for i in self.filters.indices {
            self.filters[i].apply(heuristics: heuristics)
        }
    }
}

struct Override {
    var name: String
    var filterOverride: FilterOverride

    enum FilterOverride {
        case input(String, InputOverride)
        case inputs([(String, InputOverride)])
    }

    enum InputOverride {
        case type(InputType)
        case valueType(ValueType)
        case defaultValue(Value)
    }
}

func defaultValue(_ type: ValueType, _ obj: Any??) -> Value? {
    guard let obj else { return nil }
    switch type {
    case .float:
        if let nsnum = obj as? NSNumber {
            return .float(nsnum.doubleValue)
        } else {
            return nil
        }
    case .int:
        if let nsnum = obj as? NSNumber {
            return .int(nsnum.intValue)
        } else {
            return nil
        }
    case .bool:
        if let nsnum = obj as? NSNumber {
            return .bool(nsnum.boolValue)
        } else {
            return nil
        }
    case .color3:
        if let color = obj as? CIColor {
            return .color3(.init(red: color.red, green: color.green, blue: color.blue))
        } else {
            return nil
        }
    case .color4:
        if let color = obj as? CIColor {
            return .color4(.init(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha))
        } else {
            return nil
        }

    // default:
    //     return nil
    case .rect:
        if let rect = obj as? CGRect {
            return .rect(rect)
        } else {
            return nil
        }
    case .vector2:
        if let vec = obj as? CIVector {
            return .vector2(.init(x: vec.x, y: vec.y))
        } else {
            return nil
        }
    case .vector3:
        if let vec = obj as? CIVector {
            return .vector3(.init(x: vec.x, y: vec.y, z: vec.z))
        } else {
            return nil
        }
    case .vector4:
        if let vec = obj as? CIVector {
            return .vector4(.init(x: vec.x, y: vec.y, z: vec.z, w: vec.w))
        } else {
            return nil
        }
    case .image: return nil
    case .lut: return nil
    case .string:
        if let str = obj as? String {
            return .string(str)
        } else {
            return nil
        }
    case .data:
        if let data = obj as? Data {
            return .data(data)
        } else {
            return nil
        }
    case .colorSpace:
        let cgSpace = obj! as! CGColorSpace
        if let name = cgSpace.name as? String {
            return .colorSpace(.named(name))
        } else {
            return nil
        }
    case .attributedString: return nil
    case .affineTransform:
        if let transform = obj as? NSAffineTransform {
            let t = transform.transformStruct
            return .affineTransform(.init(m11: t.m11, m12: t.m12, m21: t.m21, m22: t.m22, tX: t.tX, tY: t.tY))
        } else {
            return nil
        }
    case .matrix3x3, .matrix5x5, .matrix7x7:
        fatalError()
    }
}

func valueType(_ className: InputClassName, _ type: InputType?) -> ValueType? {
    if let type {
        switch type {
        case .angle:
            if className != .nsNumber {
                return nil
            }
            return .float
        case .boolean:
            if className != .nsNumber {
                return nil
            }
            return .bool
        case .color:
            if className != .ciColor {
                return nil
            }
            return .color4
        case .count:
            if className != .nsNumber {
                return nil
            }
            return .int
        case .distance:
            if className != .nsNumber {
                return nil
            }
            return .float
        case .gradient:
            if className != .ciImage {
                return nil
            }
            return .image
        case .image:
            if className != .ciImage {
                return nil
            }
            return .image
        case .integer:
            if className != .nsNumber {
                return nil
            }
            return .int
        case .offset:
            if className != .ciVector {
                return nil
            }
            return .vector2
        case .opaqueColor:
            if className != .ciColor {
                return nil
            }
            return .color3
        case .position:
            if className != .ciVector {
                return nil
            }
            return .vector2
        case .position3:
            if className != .ciVector {
                return nil
            }
            return .vector3
        case .rectangle:
            if className != .ciVector {
                return nil
            }
            return .rect
        case .scalar:
            if className != .nsNumber {
                return nil
            }
            return .float
        case .time:
            if className != .nsNumber {
                return nil
            }
            return .float
        case .transform:
            if className != .nsAffineTransform {
                return nil
            }
            return .affineTransform
        }
    } else {
        switch className {
        case .ciColor:
            return .color4
        case .ciImage:
            return .image
        case .ciVector:
            return .vector2
        case .nsAffineTransform:
            return .affineTransform
        // case .nsArray:
        //     return .arr
        case .nsAttributedString:
            return .attributedString
        case .nsData:
            return .data
        case .nsNumber:
            return .float
        case .nsObject:
            return .colorSpace
        case .nsString:
            return .string
        }
    }
}

enum Heuristics {
    case countIsCount
    case radiusIsDistance
}

public struct FilterInfo: Sendable, Hashable, Codable {
    public var name: String
    public var displayName: String
    public var category: FilterCategory
    public var description: String?
    public var docs: URL?
    public var availableIOS: String?
    public var availableMacOS: String?
    public var inputs: [FilterInput]

    func applying(override: Override.FilterOverride) -> Self {
        var result = self
        switch override {
        case .input(let inputName, let override):
            if let index = self.inputs.firstIndex(where: { $0.name == inputName }) {
                result.inputs[index] = self.inputs[index].applying(override: override)
            }
        case .inputs(let overrides):
            for (inputName, override) in overrides {
                if let index = self.inputs.firstIndex(where: { $0.name == inputName }) {
                    result.inputs[index] = self.inputs[index].applying(override: override)
                }
            }
        }
        return result
    }

    mutating func apply(heuristics: Heuristics) {
        for i in self.inputs.indices {
            self.inputs[i].apply(heuristics: heuristics)
        }
    }
}

public enum FilterCategory: String, Sendable, Hashable, Codable, CaseIterable {
    case blur
    case colorAdjustment
    case colorEffect
    case compositeOperation
    case distortionEffect
    case generator
    case geometryAdjustment
    case gradient
    case halftoneEffect
    case reduction
    case sharpen
    case stylize
    case tileEffect
    case transition
    case video

    public init?(rawValue: String) {
        switch rawValue {
        case kCICategoryBlur: self = .blur
        case kCICategoryColorAdjustment: self = .colorAdjustment
        case kCICategoryColorEffect: self = .colorEffect
        case kCICategoryCompositeOperation: self = .compositeOperation
        case kCICategoryDistortionEffect: self = .distortionEffect
        case kCICategoryGenerator: self = .generator
        case kCICategoryGeometryAdjustment: self = .geometryAdjustment
        case kCICategoryGradient: self = .gradient
        case kCICategoryHalftoneEffect: self = .halftoneEffect
        case kCICategoryReduction: self = .reduction
        case kCICategorySharpen: self = .sharpen
        case kCICategoryStylize: self = .stylize
        case kCICategoryTileEffect: self = .tileEffect
        case kCICategoryTransition: self = .transition
        case kCICategoryVideo: self = .video
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .blur: kCICategoryBlur
        case .colorAdjustment: kCICategoryColorAdjustment
        case .colorEffect: kCICategoryColorEffect
        case .compositeOperation: kCICategoryCompositeOperation
        case .distortionEffect: kCICategoryDistortionEffect
        case .generator: kCICategoryGenerator
        case .geometryAdjustment: kCICategoryGeometryAdjustment
        case .gradient: kCICategoryGradient
        case .halftoneEffect: kCICategoryHalftoneEffect
        case .reduction: kCICategoryReduction
        case .sharpen: kCICategorySharpen
        case .stylize: kCICategoryStylize
        case .tileEffect: kCICategoryTileEffect
        case .transition: kCICategoryTransition
        case .video: kCICategoryVideo
        }
    }
}

public struct FilterInput: Sendable, Hashable, Codable {
    public var name: String
    public var displayName: String?
    public var description: String?
    public var className: InputClassName
    public var type: InputType?
    public var min: Double?
    public var max: Double?
    public var sliderMin: Double?
    public var sliderMax: Double?
    public var valueType: ValueType
    public var defaultValue: Value?
    public var identity: Value?
    // var defaultValue: ???
    // var identity: ???
    //

    func applying(override: Override.InputOverride) -> Self {
        var result = self
        switch override {
        case .type(let type):
            result.type = type
        case .valueType(let valueType):
            result.valueType = valueType
        case .defaultValue(let value):
            result.defaultValue = value
            result.valueType = value.type
        }
        return result
    }

    mutating func apply(heuristics: Heuristics) {
        switch heuristics {
        case .countIsCount:
            if self.name.lowercased().contains("count") {
                self.type = .count
                self.valueType = .int
                if let defaultValue = self.defaultValue {
                    switch defaultValue {
                    case .float(let value):
                        self.defaultValue = .int(Int(value))
                    default: break
                    }
                }
                if let identity = self.identity {
                    switch identity {
                    case .float(let value):
                        self.identity = .int(Int(value))
                    default: break
                    }
                }
            }
        case .radiusIsDistance:
            if self.name.lowercased().contains("radius") && self.type == .scalar && self.valueType == .float {
                self.type = .distance
            }
            break
        }
    }
}

public enum InputClassName: String, Sendable, Codable {
    case nsAffineTransform = "NSAffineTransform"
    case ciColor = "CIColor"
    case nsData = "NSData"
    case ciVector = "CIVector"
    case nsObject = "NSObject"
    case nsString = "NSString"
    case nsNumber = "NSNumber"
    // case nsArray = "NSArray"
    case nsAttributedString = "NSAttributedString"
    case ciImage = "CIImage"
}

public enum InputType: String, Sendable, Codable {
    case time
    case scalar
    case distance
    case angle
    case boolean
    case integer
    case count
    case position
    case offset
    case position3
    case rectangle
    case color
    case opaqueColor
    case gradient
    case image
    case transform

    public init?(rawValue: String) {
        switch rawValue {
        case kCIAttributeTypeTime: self = .time
        case kCIAttributeTypeScalar: self = .scalar
        case kCIAttributeTypeDistance: self = .distance
        case kCIAttributeTypeAngle: self = .angle
        case kCIAttributeTypeBoolean: self = .boolean
        case kCIAttributeTypeInteger: self = .integer
        case kCIAttributeTypeCount: self = .count
        case kCIAttributeTypePosition: self = .position
        case kCIAttributeTypeOffset: self = .offset
        case kCIAttributeTypePosition3: self = .position3
        case kCIAttributeTypeRectangle: self = .rectangle
        case kCIAttributeTypeColor: self = .color
        case kCIAttributeTypeOpaqueColor: self = .opaqueColor
        case kCIAttributeTypeGradient: self = .gradient
        case kCIAttributeTypeImage: self = .image
        case kCIAttributeTypeTransform: self = .transform
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .time: return kCIAttributeTypeTime
        case .scalar: return kCIAttributeTypeScalar
        case .distance: return kCIAttributeTypeDistance
        case .angle: return kCIAttributeTypeAngle
        case .boolean: return kCIAttributeTypeBoolean
        case .integer: return kCIAttributeTypeInteger
        case .count: return kCIAttributeTypeCount
        case .position: return kCIAttributeTypePosition
        case .offset: return kCIAttributeTypeOffset
        case .position3: return kCIAttributeTypePosition3
        case .rectangle: return kCIAttributeTypeRectangle
        case .color: return kCIAttributeTypeColor
        case .opaqueColor: return kCIAttributeTypeOpaqueColor
        case .gradient: return kCIAttributeTypeGradient
        case .image: return kCIAttributeTypeImage
        case .transform: return kCIAttributeTypeTransform
        }
    }
}
