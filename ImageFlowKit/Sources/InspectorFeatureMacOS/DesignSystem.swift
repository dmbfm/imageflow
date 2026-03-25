import Helpers

struct DS {
    static let textInputBackground: DynamicColor =
        .init(
            lightColor: .grayscale(.init(white: 0.83)),
            darkColor: .grayscale(.init(white: 0.21))
        )

    static let textInputSlider: DynamicColor =
        .init(
            lightColor: .rbga(.init(red: 0.536, green: 0.662, blue: 0.788)),
            darkColor: .grayscale(.init(white: 0.3))
        )

    static let textInputSliderHighlight: DynamicColor =
        .init(
            lightColor: .rbga(.init(red: 0.679, green: 0.769, blue: 0.855)),
            darkColor: .grayscale(.init(white: 0.4))
        )
}
