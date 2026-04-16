import TextInput

extension TextInputStyle {
    static let inspector: Self = .default
        .with(\.background.borderColor, .secondaryFill)
        .with(\.insets, .init(horizontal: 8, vertical: 7))
        .with(\.font, .systemFont(ofSize: 12))
}
