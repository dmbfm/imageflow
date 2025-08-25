import ArgumentParser
import CodeGen
import Foundation

@main
struct Cli: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        abstract: "",
        subcommands: [Dump.self, Gen.self]
    )
}

extension Cli {
    struct Gen: ParsableCommand {
        func run() throws {
            let filtersInfo = CodeGen.FilterInfoCollection()
            try print(filtersInfo.gen().formatted())
        }
    }
}

extension Cli {
    struct Dump: ParsableCommand {
        @Flag(help: "")

        var json: Bool = false

        func run() throws {
            let filtersInfo = CodeGen.FilterInfoCollection()

            if self.json {
                let enc = JSONEncoder()
                enc.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try! enc.encode(filtersInfo)
                print(String(data: data, encoding: .utf8)!)
            } else {
                dump(filtersInfo)
            }
        }
    }
}
