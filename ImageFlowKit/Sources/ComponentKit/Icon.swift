import Helpers
import XKit

public final class Icon: XView, WithRef {

    public var systemName: String {
        didSet {
            if self.systemName != oldValue {
                self.update()
            }
        }
    }

    public var fontConfiguration: FontConfiguration = .preferred(.body) {
        didSet {
            self.update()
        }
    }

    public var scale: XImage.SymbolScale = .medium {
        didSet {
            if self.scale != oldValue {
                self.update()
            }
        }
    }

    public var renderingMode: XImage.SymbolColorRenderingMode = .automatic {
        didSet {
            if self.renderingMode != oldValue {
                self.update()
            }
        }
    }

    public var color: ColorConfiguration = .hierarchical(nil) {
        didSet {
            self.update()
        }
    }

    public var imageView: XImageView = .init()

    public enum FontConfiguration {
        case preferred(NSFont.TextStyle)
        case custom(pointSize: CGFloat, weight: NSFont.Weight)

        func apply(_ config: XImage.SymbolConfiguration) -> XImage.SymbolConfiguration {
            config.applying(
                {
                    switch self {
                    case .preferred(let style): .init(textStyle: style)
                    case .custom(let pointSize, let weight): .init(pointSize: pointSize, weight: weight)
                    }
                }()
            )
        }
    }

    public enum ColorConfiguration {
        case monochrome(XColor?)
        case hierarchical(XColor?)
        case multicolor(XColor?)
        case palette([XColor])

        func apply(_ config: XImage.SymbolConfiguration) -> XImage.SymbolConfiguration {
            config.applying(
                {
                    switch self {
                    case .monochrome(.some(let color)):
                        .preferringMonochrome().applying(.init(hierarchicalColor: color))
                    case .monochrome(.none):
                        .preferringMonochrome()
                    case .hierarchical(.some(let color)):
                        .preferringHierarchical().applying(.init(hierarchicalColor: color))
                    case .hierarchical(.none):
                        .preferringHierarchical()
                    case .multicolor(.some(let color)):
                        .preferringMulticolor().applying(.init(hierarchicalColor: color))
                    case .multicolor(.none):
                        .preferringMulticolor()
                    case .palette(let colors):
                        .init(paletteColors: colors)
                    }
                }()
            )
        }
    }

    public init(systemName: String) {
        self.systemName = systemName

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.constraintToFillSuperview()

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var configuration: XImage.SymbolConfiguration {
        let base = XImage.SymbolConfiguration()
        return self.renderingMode.apply(self.scale.apply(self.fontConfiguration.apply(self.color.apply(base))))
    }

    func update() {
        if let image = XImage(systemSymbolName: self.systemName, accessibilityDescription: nil) {
            self.imageView.image = image
            self.imageView.imageScaling = .scaleNone
            self.imageView.symbolConfiguration = self.configuration
        }
    }
}

extension XImage.SymbolScale {
    func apply(_ config: XImage.SymbolConfiguration) -> XImage.SymbolConfiguration {
        config.applying(.init(scale: self))
    }
}

extension XImage.SymbolColorRenderingMode {
    func apply(_ config: XImage.SymbolConfiguration) -> XImage.SymbolConfiguration {
        config.applying(.init(colorRenderingMode: self))
    }
}

#Preview {
    VStack(views: [
        Icon(systemName: "plus"),
        Icon(systemName: "plus").with(\.fontConfiguration, .custom(pointSize: NSFont.systemFontSize, weight: .bold)),
        Icon(systemName: "plus")
            .with(\.color, .hierarchical(XColor.systemRed)),
    ])
}
