import Helpers
import XKit

public final class RegularGridManual: XView, WithRef {
    private var views: [XView] = []

    let numCols: Int
    let numRows: Int
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat

    func calculateGeometry() -> [CGRect] {

        let w = self.bounds.width
        let h = self.bounds.height

        let cw = (w - self.horizontalSpacing * Double(self.numCols - 1)) / Double(self.numCols)
        let ch = (h - self.verticalSpacing * Double(self.numRows - 1)) / Double(self.numRows)

        var rects: [CGRect] = []

        for col in 0..<self.numCols {
            for row in 0..<self.numRows {
                let rect = CGRect(
                    x: (cw + self.horizontalSpacing) * Double(col),
                    y: (ch + self.verticalSpacing) * Double(row),
                    width: cw,
                    height: ch
                )
                rects.append(rect)
            }
        }

        return rects
    }

    public init(_ numCols: Int, verticalSpacing: CGFloat = 4.0, horizontalSpacing: CGFloat = 4.0, views: [XView]) {
        self.numCols = numCols
        self.numRows = (views.count / numCols) + (views.count % numCols == 0 ? 0 : 1)
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing

        super.init(frame: .zero)

        for i in 0..<(numRows * numCols) {
            self.views.append(views[tryGetAt: i] ?? XView())
        }

        for view in self.views {
            self.addSubview(view)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: NSSize {
        .init(
            width: Self.noIntrinsicMetric,
            height: Double(self.numRows) * 24
                + (Double(self.numRows - 1) * self.verticalSpacing)
        )
    }

    public override func layout() {
        let rects = self.calculateGeometry()
        // print("rects: \(rects)")

        for col in 0..<self.numCols {
            for row in 0..<self.numRows {
                let index = col * self.numCols + row
                self.views[index].frame = rects[index]
            }
        }
    }
}

public final class RegularGrid: XView, WithRef {

    private var views: [XView] = []

    public init(_ numCols: Int, verticalSpacing: CGFloat = 4.0, horizontalSpacing: CGFloat = 4.0, views: [XView]) {

        super.init(frame: .zero)

        let numRows = (views.count / numCols) + (views.count % numCols == 0 ? 0 : 1)

        for i in 0..<(numRows * numCols) {
            self.views.append(views[tryGetAt: i] ?? XView())
        }

        var anchor = self.leadingAnchor
        for col in 0..<numCols {
            let colViews = (0..<numRows).reduce(
                [],
                { acc, index in
                    acc.appending(self.views[col + index * numCols])
                }
            )

            let stack = VStack(alignment: .fill, spacing: verticalSpacing, views: colViews)
                .with(\.distribution, .equalCentering)
                .with(\.translatesAutoresizingMaskIntoConstraints, false)
            self.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.widthAnchor.constraint(
                    equalTo: self.widthAnchor,
                    multiplier: 1.0 / Double(numCols),
                    constant: -horizontalSpacing * Double(numCols - 1) / Double(numCols)
                ),
                stack.leadingAnchor.constraint(equalTo: anchor, constant: col == 0 ? 0 : horizontalSpacing),
                stack.topAnchor.constraint(equalTo: self.topAnchor),
                stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
            anchor = stack.trailingAnchor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RedView: XView {
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        self.withLayer({ $0.backgroundColor = .red })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    RegularGridManual(2, views: [RedView(), RedView(), RedView(), RedView()])
}

#Preview {
    RegularGrid(
        8,
        views: [
            RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(),
            RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(),
            RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(),
            RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(), RedView(),
        ]
    )
}
