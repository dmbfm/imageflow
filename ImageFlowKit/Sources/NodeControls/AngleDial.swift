import CommonUtils
import SwiftUI

struct AngleDial: View {
    // @State var angle: Angle = .degrees(0)
    @Binding var angle: Double
    @State var hover: Bool = false

    func updateAngle(_ location: CGPoint) {
        let center = CGPoint(x: 40, y: 40)
        let p = location - center

        #if os(macOS)
            let angle =
                if NSEvent.modifierFlags.contains(.shift) {
                    atan2(-p.y, p.x).snapped(toDivisions: 8, as: .radians)
                } else {
                    atan2(-p.y, p.x)
                }
        #else
            let angle = atan2(-p.y, p.x)
        #endif

        self.angle = angle.snapped(toDivisions: 360, as: .radians).normalized(as: .radians)

        print("angle: \(self.angle)")
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.8))
            Circle()
                .fill(
                    Color(white: 0.90)
                        .shadow(
                            .inner(
                                color: Color(white: 0.75),
                                radius: 4,
                                x: -4,
                                y: -4
                            )
                        ).shadow(
                            .inner(
                                color: Color(white: 0.98),
                                radius: 4,
                                x: 2,
                                y: 2
                            )
                        )
                )
                //                .padding(1)
                .padding(2)

            Group {
                Circle()
                    .fill(Color(hue: 0.606, saturation: 0.307, brightness: 0.837, opacity: 1.0))
                    .frame(width: 10)
                    .offset(x: 30)

                Circle()
                    .fill(
                        Color(hue: 0.606, saturation: 0.253, brightness: 1.0, opacity: 1.0).shadow(
                            .inner(color: .init(white: 0, opacity: 0.18), radius: 1, x: 1, y: 1)
                        )
                    )
                    .frame(width: 8)
                    .rotationEffect(.radians(self.angle))
                    .offset(x: 30)
            }
            .rotationEffect(.radians(-self.angle))

            Circle()
                .fill(.black.opacity(self.hover ? 0 : 0.025))
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { value in
                self.updateAngle(value.location)
            }
        )
        .onHover { value in
            self.hover = value
        }
        .frame(width: 80, height: 80)
        .scaleEffect(0.60)
    }
}

/// Unit in which angles are expressed.
public enum AngleUnit {
    case degrees
    case radians
}

public extension CGFloat {
    /// Snap this angle to the nearest division of the circle.
    ///
    /// - Parameters:
    ///   - divisions: Number of equal slices of the circle (must be ≥ 1).
    ///   - unit: Whether `self` (and the result) are in `.degrees` or `.radians`.
    /// - Returns: The angle snapped to the closest multiple of (full circle / divisions).
    func snapped(toDivisions divisions: Int, as unit: AngleUnit = .degrees) -> CGFloat {
        guard divisions > 0 else { return self }

        // Determine full-circle measure in chosen units
        let fullCircle: CGFloat = {
            switch unit {
            case .degrees: return 360.0
            case .radians: return 2.0 * .pi
            }
        }()

        // Normalize into [0, fullCircle)
        var angle = self.truncatingRemainder(dividingBy: fullCircle)
        if angle < 0 { angle += fullCircle }

        // Size of each slice
        let slice = fullCircle / CGFloat(divisions)

        // Find nearest slice index
        let index = (angle / slice).rounded()

        // Return the snapped angle (allows the final value to be exactly fullCircle)
        return index * slice
    }

    /// Normalize this angle into the [0…fullCircle] range.
    ///
    /// - Parameter unit: Whether `self` is in `.degrees` or `.radians`.
    /// - Returns: An equivalent angle in the range [0…360] (degrees) or [0…2π] (radians).
    func normalized(as unit: AngleUnit = .degrees) -> CGFloat {
        // Determine full‑circle measure
        let fullCircle: CGFloat = {
            switch unit {
            case .degrees: return 360.0
            case .radians: return 2.0 * .pi
            }
        }()

        // Compute remainder in (–fullCircle…fullCircle)
        var angle = self.truncatingRemainder(dividingBy: fullCircle)

        // Shift negatives into [0…fullCircle)
        if angle < 0 {
            angle += fullCircle
        }

        // Optionally, if you want 0 to map to fullCircle when the original angle
        // was exactly a positive multiple of fullCircle, you could do:
        // if angle == 0 && self > 0 {
        //     return fullCircle
        // }

        return angle
    }

}

#Preview {
    @Previewable @State var angle: Double = 0
    VStack {
        AngleDial(angle: $angle)
        Button("OK") {}
    }
    .padding(100)
    .background(.white)

}
