import SwiftUI

public struct OpacityLevelShapeStyle: ShapeStyle {
    var lightValue: Double
    var darkValue: Double

    public init(_ value: Double) {
        self.lightValue = value
        self.darkValue = value
    }

    public init(light: Double, dark: Double) {
        self.lightValue = light
        self.darkValue = dark
    }

    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.colorScheme == .dark {
            Color(white: 1.0, opacity: self.darkValue)
        } else {
            Color(white: 0.0, opacity: self.lightValue)
        }
    }
}

public struct PrimaryFillShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.10)
    }
}

public struct SecondaryFillShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.08)
    }
}

public struct TertiaryFillShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.05)
    }
}

public struct QuaternaryFillShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.03)
    }
}

public struct QuinaryFillShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.02)
    }
}

extension ShapeStyle where Self == SecondaryFillShapeStyle {
    public static var secondaryFill: SecondaryFillShapeStyle { .init() }
}

extension ShapeStyle where Self == PrimaryFillShapeStyle {
    public static var primaryFill: PrimaryFillShapeStyle { .init() }
}

extension ShapeStyle where Self == TertiaryFillShapeStyle {
    public static var tertiaryFill: TertiaryFillShapeStyle { .init() }
}

extension ShapeStyle where Self == QuaternaryFillShapeStyle {
    public static var quaternaryFill: QuaternaryFillShapeStyle { .init() }
}

extension ShapeStyle where Self == QuinaryFillShapeStyle {
    public static var quinaryFill: QuinaryFillShapeStyle { .init() }
}

public struct PrimaryLabelShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.85)
    }
}

public struct SecondaryLabelShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(light: 0.5, dark: 0.55)
    }
}

public struct TertiaryLabelShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.25)
    }
}

public struct QuaternaryLabelShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.10)
    }
}

public struct QuinaryLabelShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.05)
    }
}

public struct SeximalLabelShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        OpacityLevelShapeStyle(0.03)
    }
}

extension ShapeStyle where Self == PrimaryLabelShapeStyle {
    public static var primaryLabel: PrimaryLabelShapeStyle { .init() }
}

extension ShapeStyle where Self == SecondaryLabelShapeStyle {
    public static var secondaryLabel: SecondaryLabelShapeStyle { .init() }
}

extension ShapeStyle where Self == TertiaryLabelShapeStyle {
    public static var tertiaryLabel: TertiaryLabelShapeStyle { .init() }
}

extension ShapeStyle where Self == QuaternaryLabelShapeStyle {
    public static var quaternaryLabel: QuaternaryLabelShapeStyle { .init() }
}

extension ShapeStyle where Self == QuinaryLabelShapeStyle {
    public static var quinaryLabel: QuinaryLabelShapeStyle { .init() }
}

extension ShapeStyle where Self == SeximalLabelShapeStyle {
    public static var seximalLabel: SeximalLabelShapeStyle { .init() }
}

private struct Card<S: ShapeStyle>: View {
    var label: String
    var style: S

    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(style)
                .frame(width: 200, height: 100)

            Text(label)
                .fontDesign(.monospaced)
        }
    }
}

#Preview("Fill Styles") {
    VStack(alignment: .leading) {
        HStack {
            Card(label: ".primaryFill", style: .primaryFill)
            Card(label: ".secondaryFill", style: .secondaryFill)
            Card(label: ".tertiaryFill", style: .tertiaryFill)
        }
        HStack {
            Card(label: ".quaternaryFill", style: .quaternaryFill)
            Card(label: ".quinaryFill", style: .quinaryFill)
        }
    }
    .padding()
}

#Preview("Label Styles") {
    VStack {
        Text("Primary Label")
            .foregroundStyle(.primaryLabel)
        Text("Secondary Label")
            .foregroundStyle(.secondaryLabel)
        Text("Tertiary Label")
            .foregroundStyle(.tertiaryLabel)
        Text("Quaternary Label")
            .foregroundStyle(.quaternaryLabel)
        Text("Quinary Label")
            .foregroundStyle(.quinaryLabel)
        Text("Seximal Label")
            .foregroundStyle(.seximalLabel)
    }
    .padding()
}

#Preview("Stacking") {
    ZStack {
        RoundedRectangle(cornerRadius: 4)
            .fill(.primaryFill)
            .frame(width: 200, height: 200)
        RoundedRectangle(cornerRadius: 4)
            .fill(.primaryFill)
            .frame(width: 150, height: 150)
        RoundedRectangle(cornerRadius: 4)
            .fill(.primaryFill)
            .frame(width: 75, height: 75)
    }
    .padding()
}
