import Foundation
import Logging

extension Logger.Level {
    init(from level: String?) {
        switch level?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "trace":
            self = .trace
        case "debug":
            self = .debug
        case "info":
            self = .info
        case "notice":
            self = .notice
        case "warning":
            self = .warning
        case "error":
            self = .error
        case "critical":
            self = .critical
        default:
            self = .info
        }
    }
}

extension Logger {
    static func createWithLevelFromEnv(fileName: String) -> Logger {
        let className = fileName.split(separator: ".").dropLast().joined(separator: ".")

        var logger = Logger(label: className)
        logger.logLevel = Logger.Level(from: ProcessInfo.processInfo.environment["LOGGER_LEVEL"])

        return logger
    }
}