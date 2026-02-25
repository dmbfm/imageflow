import Helpers
import Logging
import SwiftUI

public struct BlockGridLayout: Layout {
    let configuration: Configuartion

    public init(_ configuration: Configuartion) {
        self.configuration = configuration
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        assert(self.configuration.viewCount == subviews.count)
        let proposal = proposal.replacingUnspecifiedDimensions()

        var height =
            self.rowHeights(subviews: subviews).reduce(0.0, +)
            + (self.configuration.verticalSpacing
                * CGFloat(self.configuration.rowCount - 1))

        height +=
            CGFloat(self.configuration.properties.count(where: { $0 == .largeControl }))
            * self.configuration.idealRowHeight

        return .init(width: proposal.width, height: height)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        assert(self.configuration.viewCount == subviews.count)
        let rowHeights = self.rowHeights(subviews: subviews)
        let captionColumnWidth = self.configuration.indicesForCaptions().reduce(
            0.0,
            { acc, index in
                max(acc, subviews[index].sizeThatFits(.unspecified).width)
            }
        )
        let trailingColumnWidth = self.configuration.indicesForTrailings().reduce(
            0.0,
            { acc, index in
                max(acc, subviews[index].sizeThatFits(.unspecified).width)
            }
        )
        let labelColumnWidth =
            self.configuration.labelWidthPercent * bounds.width - captionColumnWidth
            - self.configuration.horizontalSpacing.label - self.configuration.horizontalSpacing.caption

        let controlColumnWidth =
            (1.0 - self.configuration.labelWidthPercent) * bounds.width
            - trailingColumnWidth - self.configuration.horizontalSpacing.control

        var p: CGPoint = bounds.origin
        for (idx, (property, row)) in self.configuration.indicesForRowsEx().enumerated() {
            p.x = bounds.origin.x
            let rowHeight = rowHeights[idx]
            let midY = p.y + rowHeight * 0.5
            let isLargeControl = property == .largeControl
            let useIdealRowHeight = property == .custom || property == .largeControl
            let midYIdeal = useIdealRowHeight ? p.y + self.configuration.idealRowHeight * 0.5 : midY

            if row.count == 4 {
                {
                    let label = subviews[row[0]]
                    let size = label.sizeThatFits(.unspecified)
                    // let mid =
                    label.place(
                        at: .init(x: p.x, y: midYIdeal - size.height * 0.5),
                        proposal: .init(width: labelColumnWidth, height: size.height)
                    )
                    p.x += labelColumnWidth + self.configuration.horizontalSpacing.label
                }()
            } else {
                p.x += labelColumnWidth + self.configuration.horizontalSpacing.label
            }

            _ = {
                let index = row.count == 4 ? 1 : 0
                let caption = subviews[row[index]]
                let size = caption.sizeThatFits(.unspecified)
                caption.place(
                    at: .init(x: p.x + captionColumnWidth, y: midYIdeal - size.height * 0.5),
                    anchor: .topTrailing,
                    proposal: .init(width: captionColumnWidth, height: size.height)
                )
                p.x += captionColumnWidth + self.configuration.horizontalSpacing.caption
            }()

            _ = {
                let index = row.count == 4 ? 2 : 1
                let control = subviews[row[index]]
                let size = control.sizeThatFits(.unspecified)
                if isLargeControl {
                    control.place(
                        at: .init(
                            x: bounds.origin.x,
                            y: p.y + self.configuration.idealRowHeight
                                // y: midY - size.height * 0.5
                        ),
                        proposal: .init(width: bounds.width, height: size.height)
                    )
                    p.x += controlColumnWidth + self.configuration.horizontalSpacing.control
                } else {
                    control.place(
                        at: .init(x: p.x, y: midY - size.height * 0.5),
                        proposal: .init(width: controlColumnWidth, height: size.height)
                    )
                    p.x += controlColumnWidth + self.configuration.horizontalSpacing.control
                }
            }()

            if row.count == 4 {
                let trailing = subviews[row[3]]
                let size = trailing.sizeThatFits(.unspecified)
                trailing.place(
                    at: .init(x: p.x, y: midYIdeal - size.height * 0.5),
                    proposal: .init(width: trailingColumnWidth, height: size.height)
                )
                p.x += trailingColumnWidth
            }

            p.y += rowHeight + self.configuration.verticalSpacing

            if isLargeControl {
                p.y += self.configuration.idealRowHeight
            }
        }
    }

    func labels(subviews: Subviews) -> Subviews {
        subviews[0...2]
    }

    func rowHeights(subviews: Subviews) -> [CGFloat] {
        self.configuration.indicesForRows().map { row in
            row.reduce(
                0.0,
                { acc, index in
                    max(acc, subviews[index].sizeThatFits(.unspecified).height)
                }
            )
        }
    }
}

extension BlockGridLayout {
    struct LayoutData {
        var frames: [CGRect]
    }
}

extension BlockGridLayout {
    public struct Configuartion: Sendable, With {
        public var idealRowHeight: CGFloat = 28.0
        public var labelAlignment: HorizontalAlignment = .leading
        public var labelWidthPercent: CGFloat = 0.4
        public var horizontalSpacing: HorizontalSpacing = .init()
        public var verticalSpacing: CGFloat = 4.0
        public var properties: [Property]

        public var viewCount: Int {
            self.properties.reduce(0, { acc, p in acc + p.viewCount })
        }

        public enum Property: Sendable, Equatable {
            case rows(Int)
            case largeControl
            case custom

            var viewCount: Int {
                switch self {
                case .rows(let count):
                    2 + (2 * count)
                case .custom, .largeControl:
                    4
                }
            }
        }

        public struct HorizontalSpacing: Sendable, With {
            public var label: CGFloat = 4.0
            public var caption: CGFloat = 0.0
            public var control: CGFloat = 2.0

            var total: CGFloat { label + caption + control }

            public init(label: CGFloat = 4.0, caption: CGFloat = 2.0, control: CGFloat = 2.0) {
                self.label = label
                self.caption = caption
                self.control = control
            }
        }

        public init(
            idealRowHeight: CGFloat = 28.0,
            labelAlignment: HorizontalAlignment = .leading,
            horizontalSpacing: HorizontalSpacing = .init(),
            verticalSpacing: CGFloat = 4.0,
            labelWidthPercent: CGFloat = 0.3,
            properties: [BlockGridLayout.Configuartion.Property]
        ) {
            self.idealRowHeight = idealRowHeight
            self.labelAlignment = labelAlignment
            self.properties = properties
            self.horizontalSpacing = horizontalSpacing
            self.verticalSpacing = verticalSpacing
            self.labelWidthPercent = labelWidthPercent
        }

        var rowCount: Int {
            self.properties.reduce(
                0,
                { acc, p in
                    switch p {
                    case .custom, .largeControl: acc + 1
                    case .rows(let n): acc + n
                    }
                }
            )
        }

        func indicesForRows() -> [[Int]] {
            var result = [[Int]]()
            var current: Int = 0
            for p in self.properties {
                switch p {
                case .custom, .largeControl:
                    result.append([current, current + 1, current + 2, current + 3])
                    current += p.viewCount
                case .rows(1):
                    result.append([current, current + 1, current + 2, current + 3])
                    current += p.viewCount
                case .rows(let count):
                    result.append([current, current + 1, current + 2, current + p.viewCount - 1])
                    current += 3

                    for _ in 1..<count {
                        result.append([current, current + 1])
                        current += 2
                    }

                    current += 1
                }
            }
            return result
        }

        func indicesForRowsEx() -> [(Property, [Int])] {
            var result = [(Property, [Int])]()
            var current: Int = 0
            for p in self.properties {
                switch p {
                case .custom, .largeControl:
                    result.append((p, [current, current + 1, current + 2, current + 3]))
                    current += p.viewCount
                case .rows(1):
                    result.append((p, [current, current + 1, current + 2, current + 3]))
                    current += p.viewCount
                case .rows(let count):
                    result.append((p, [current, current + 1, current + 2, current + p.viewCount - 1]))
                    current += 3

                    for _ in 1..<count {
                        result.append((p, [current, current + 1]))
                        current += 2
                    }

                    current += 1
                }
            }
            return result
        }

        func indicesForLabels() -> [Int] {
            var result = [Int]()
            var current: Int = 0
            for p in self.properties {
                result.append(current)
                current += p.viewCount
            }
            return result
        }

        func indicesForCaptions() -> [Int] {
            var result = [Int]()
            var current: Int = 1
            for p in self.properties {
                switch p {
                case .rows(1):
                    result.append(current)
                    current += 4
                case .rows(let count):
                    for i in 0..<count {
                        result.append(current)
                        current += i == (count - 1) ? 4 : 2
                    }
                case .custom, .largeControl:
                    result.append(current)
                    current += 4
                }
            }
            return result
        }

        func indicesForControls() -> [Int] {
            var result = [Int]()
            var current: Int = 2
            for p in self.properties {
                switch p {
                case .rows(let count):
                    for i in 0..<count {
                        result.append(current)
                        current += i == 0 ? 3 : 2
                    }
                case .custom, .largeControl:
                    result.append(current)
                    current += 4
                }
            }
            return result
        }

        func indicesForTrailings() -> [Int] {
            var result = [Int]()
            var current: Int = 0
            for p in self.properties {
                current += p.viewCount - 1
                result.append(current)
                current += 1
            }
            return result
        }
    }
}

// MARK: - Previews

extension BlockGridLayout {
    public struct Preview: View {

        public init() {}

        public var body: some View {
            VStack {
                BlockGridLayout(
                    .init(properties: [
                        .rows(1),
                        .rows(2),
                        .rows(1),
                        .custom,
                        .rows(3),
                    ])
                ) {

                    // 1
                    Text("Value")
                    Text("float")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))
                    Button {
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    // 2
                    Text("Vector")

                    Text("x")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))

                    Text("y")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))

                    Button {
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    // 3
                    Text("Value")
                    Text("float")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))
                    Button {
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    // 4
                    Text("Curves")

                    Text("")

                    Rectangle()
                        .fill(.red)
                        .frame(width: nil, height: 200)

                    Button {
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    // 5
                    Text("Vector")

                    Text("x")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))

                    Text("y")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))

                    Text("z")
                        .font(.caption2)
                    TextField("", text: .constant("3.141516"))

                    Button {
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                }
                .border(.orange)

                Spacer()
            }
            .padding()
        }
    }
}
