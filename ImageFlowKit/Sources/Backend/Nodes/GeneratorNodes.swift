import CoreImage
import CoreImage.CIFilterBuiltins
import Filters
import GameKit
import SceneKit
import Values
import XKit

extension Nodes {
    public struct Generator {
        static var simplexNoise: NodeImpl {
            let schema = NodeSchema(
                name: "Simplex Noise",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Scale", defaultValue: .float(64.0)),
                    .init(name: "Seed", defaultValue: .int(0), semantics: .count),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in

                    let width = node.inputs[0].int
                    let height = node.inputs[1].int
                    let scale = node.inputs[2].float
                    let seed = node.inputs[3].float

                    let gm = GKMersenneTwisterRandomSource.init(seed: UInt64(seed.magnitude))
                    let x = CGFloat(floor(gm.nextUniform() * 512))
                    let y = CGFloat(floor(gm.nextUniform() * 512))

                    let filter = SimplexNoiseFilter()
                    filter.scale = Float(scale)
                    node.outputs[0].image = await context.addImage(
                        filter.outputImage?.cropped(
                            to: .init(
                                x: x,
                                y: y,
                                width: CGFloat(width),
                                height: CGFloat(height)
                            )
                        ).transformed(by: .init(translationX: -x, y: -y)),
                        0
                    )
                }
            )
        }

        static var shadedSphere: NodeImpl {
            let schema = NodeSchema(
                name: "Shaded Sphere",
                inputs: [
                    .init(
                        name: "Color",
                        defaultValue: .color4(.init(red: 0.214, green: 0.458, blue: 0.732, alpha: 1.0))
                    ),
                    .init(name: "Shininess", defaultValue: .float(0.5), semantics: .float(.range(0...1))),
                    .init(
                        name: "Light Color",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0))
                    ),
                    .init(name: "Light Position", defaultValue: .vector3(.init(x: 1.0, y: 0.5, z: 1.0))),
                    .init(name: "Light Intensity", defaultValue: .float(0.5), semantics: .float(.range(0...1))),
                    .init(
                        name: "Ambient Color",
                        defaultValue: .color4(.init(red: 0.5, green: 0.5, blue: 0.75, alpha: 1.0))
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            let scene = SCNScene()
            var omni: SCNLight {
                let light = SCNLight()
                light.color = NSColor.systemCyan
                light.type = .omni
                light.intensity = 900
                return light
            }
            var ambient: SCNLight {
                let light = SCNLight()
                light.color = NSColor.systemGray
                light.type = .ambient
                light.intensity = 1_000
                return light
            }

            let camera = SCNCamera()
            camera.usesOrthographicProjection = true
            camera.orthographicScale = 1

            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = .init(0, 0, 2)

            let sphere = SCNSphere(radius: 1)
            let sphereNode = SCNNode(geometry: sphere)

            let omniNode = SCNNode()
            omniNode.light = omni
            omniNode.position = .init(50, 50, 10)

            let ambientNode = SCNNode()
            ambientNode.light = ambient

            scene.rootNode.addChildNode(cameraNode)
            scene.rootNode.addChildNode(ambientNode)
            scene.rootNode.addChildNode(omniNode)
            scene.rootNode.addChildNode(sphereNode)

            let material = SCNMaterial()
            material.lightingModel = .blinn
            material.specular.contents = NSColor.white
            material.diffuse.contents = NSColor.systemBlue
            material.shininess = 0.05
            sphere.materials = [material]

            let renderer = SCNRenderer(device: nil)
            renderer.scene = scene

            struct CacheKey: Equatable {
                let diffuseColor: Color4
                let shininess: Double
                let lightColor: Color4
                let lightPos: Vector3
                let lightIntensity: Double
                let ambientColor: Color4
            }

            var cache: (CacheKey, CIImage)? = nil

            return .init(schema: schema) { node, context in

                let diffuseColor = node.inputs[0].color4
                let shininess = node.inputs[1].float
                let lightColor = node.inputs[2].color4
                let lightPos = node.inputs[3].vector3
                let lightIntensity = node.inputs[4].float
                let ambientColor = node.inputs[5].color4

                let nextKey = CacheKey(
                    diffuseColor: diffuseColor,
                    shininess: shininess,
                    lightColor: lightColor,
                    lightPos: lightPos,
                    lightIntensity: lightIntensity,
                    ambientColor: ambientColor
                )

                if let cache, nextKey == cache.0 {
                    node.outputs[0] = .image(await context.addImage(cache.1, 0))
                    return
                }

                material.shininess = max(pow(shininess, 4), 0.01)
                material.diffuse.contents = diffuseColor.nsColor

                omniNode.position.x = lightPos.x * 50.0
                omniNode.position.y = lightPos.y * 50.0  //-50.0 + (node.inputs[3].vector2.y * 100.0)
                omniNode.position.z = lightPos.z * 50.0
                omniNode.light?.color = lightColor.nsColor
                omniNode.light?.intensity = 10_000 * pow(lightIntensity, 4)
                ambientNode.light?.color = ambientColor.nsColor

                let image = renderer.snapshot(atTime: 0, with: .init(width: 512, height: 512), antialiasingMode: .none)
                let ciImage = CIImage(bitmapImageRep: .init(data: image.tiffRepresentation!)!)
                if let ciImage {
                    node.outputs[0] = .image(await context.addImage(ciImage, 0))
                    cache = (nextKey, ciImage)
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }
}
