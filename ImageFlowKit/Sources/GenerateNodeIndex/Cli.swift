import SharedModels

extension String {
    var slug: String {
        self.replacing(" ", with: "-").lowercased()
    }
}

@main
struct Cli {
    static func main() {
        let p = NodePaletteService.shared.categories()

        for cat in p.filter({ $0.name != .experimental }) {
            for item in cat.items {
                if let slug = item.nodeKind.docSlug {
                    print("\(slug.0),\(cat.name.rawValue),\(slug.1),\(item.displayName)")
                }
            }
        }
    }
}
