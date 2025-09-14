import Foundation

public struct Log {
    public enum Level: Sendable, Comparable {
        case error
        case warning
        case info
        case debug
        case trace

        var emoji: String {
            switch self {
            case .error: "‼️"
            case .warning: "⚠️"
            case .info: "ℹ️"
            case .debug: "🪲"
            case .trace: "📢"
            }
        }

        var name: String {
            switch self {
            case .error: "ERROR"
            case .warning: "WARNING"
            case .info: "LOG"
            case .debug: "DEBUG"
            case .trace: "TRACE"
            }
        }
    }

    static let level: Level = .trace

    static let dateFormatStyle: Date.FormatStyle = .dateTime
        .hour()
        .minute()
        .second()
        .secondFraction(.fractional(3))

}

public func log(
    _ message: @autoclosure () -> String,
    level: Log.Level = .info,
    file: String = #file,
    linum: Int = #line,
    function: String = #function
) {
    if level <= Log.level {
        let date = Date.now.formatted(Log.dateFormatStyle)
        print(
            "\(level.emoji) [\(level.name)] [\(date):\(file):\(linum):\(function)]: \(message())"
        )
    }
}
