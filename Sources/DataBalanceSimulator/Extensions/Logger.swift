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

    func log(withLevel level: Level = .info, withDescription description: String, withProps props: [String: String]) {
        guard !props.isEmpty else {
            return self.info("\(description)")
        }
        
        var log = "\(description)\n"
        
        let keys = props.keys
        for (index, key) in keys.enumerated() {
            if index == keys.count - 1 {
                log += "    └─ \(key): \(props[key]!)\n"
            } else {
                log += "    ├─ \(key): \(props[key]!)\n"
            }
        }
        
        self.log(level: level, "\(log)")
    }
}