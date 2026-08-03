import CoreImage
import CoreImage.CIFilterBuiltins
import Filters
import Values
import XKit

extension Nodes.CoreImageCustom {

    public struct TextNodes {

        public static var textGeneratorNode: NodeImpl {
            let schema = NodeSchema(
                name: "Text Generator",
                inputs: [
                    .init(name: "Text", defaultValue: .string("Hello, World!")),
                    .init(name: "Style", defaultValue: .textStyle(.init())),
                    .init(name: "Scale", defaultValue: .float(1.0)),
                    .init(name: "Padding", defaultValue: .float(0.0)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter.attributedTextImageGenerator()
                let text = node.inputs[0].string
                let style = node.inputs[1].textStyle

                let attrs = AttributedString(
                    text,
                    attributes: .init([
                        .font: NSFont(name: style.fontName, size: style.fontSize) as Any,
                        .foregroundColor: style.foregroundColor.nsColor as Any,
                        .backgroundColor: style.backgroundColor.nsColor as Any,
                        .strokeColor: style.strokeColor.nsColor as Any,
                        .strokeWidth: NSNumber(value: -style.strokeWidth) as Any,
                        .underlineStyle: (TextStyle.UnderlineStyle.init(rawValue: style.underline) ?? .none).nsNumber
                            as Any,
                        .underlineColor: style.underlineColor.nsColor as Any,
                        .shadow:
                            (style.shadowRadius != 0.0
                            ? {
                                let s = NSShadow()
                                s.shadowColor = style.shadowColor.nsColor
                                s.shadowBlurRadius = style.shadowRadius
                                s.shadowOffset = .init(width: style.shadowOffset.x, height: style.shadowOffset.y)
                                return s
                            }() : NSNull()) as Any,
                    ])
                )

                filter.text = .init(attrs)
                filter.scaleFactor = Float(node.inputs[2].float)
                filter.padding = Float(node.inputs[3].float)
                node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
            }
        }
    }
}
