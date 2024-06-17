import Foundation

enum ConfigsValidationErrors: Error, Equatable {
    case ConfigFileDoesNotExist(filePath: String)
    case ConfigFileCannotBeOpened(reason: String)
    case ConfigFileCannotBeParsedCorrectly(reason: String)
    case ConfigPropertyIsNotInitialized(property: ConfigProperties)
    case ConfigPropertyTypeIsNotCompliant(
        property: ConfigProperties
    )
}

enum ConfigProperties: String, CaseIterable {
    case seed
    case minNodes
    case maxNodes
    case minServices
    case maxServices
    case lowerBound
    case upperBound

    func isTypeCompatibleWith(value: Any) -> Bool {
        switch self {
            case .seed: return value is Int
            case .minNodes: return value is Int
            case .maxNodes: return value is Int
            case .minServices: return value is Int
            case .maxServices: return value is Int
            case .lowerBound: return value is Float
            case .upperBound: return value is Float
        }
    }
}

class ConfigurationManager {
    var configs: [ConfigProperties: Any]

    init(simulatorCliConfigs: [ConfigProperties: Any], configFilePathOpt: String?) throws {
        self.configs = try ConfigurationManager.getConfigsFromFile(
            configFilePathOpt: configFilePathOpt)

        try self.mergeConfigsWithCLIOptions(simulatorCliConfigs: simulatorCliConfigs)

        try self.checkTypeOfConfigProperties()
    }

    // func get(property: ConfigProperties) throws -> Any {
    //     return self.con
    // }

    private func checkTypeOfConfigProperties() throws {
        precondition(configs.count == ConfigProperties.allCases.count)

        for prop in ConfigProperties.allCases {
            guard prop.isTypeCompatibleWith(value: self.configs[prop]!) else {
                throw ConfigsValidationErrors.ConfigPropertyTypeIsNotCompliant(property: prop)
            }
        }
    }

    private func mergeConfigsWithCLIOptions(
        simulatorCliConfigs: [ConfigProperties: Any]
    ) throws {
        for prop in ConfigProperties.allCases {
            self.configs[prop] = try mergeValuesForSameConfig(
                forProp: prop, 
                values: configs[prop], simulatorCliConfigs[prop]
            )
        }
    }

    private func mergeValuesForSameConfig<T>(forProp prop: ConfigProperties, values: T?...) throws -> T {
        if let configValue = values.compactMap({ $0 }).last {
            return configValue
        } else {
            throw ConfigsValidationErrors.ConfigPropertyIsNotInitialized(
                property: prop)
        }
    }

    private static func getConfigsFromFile(
        configFilePathOpt: String?
    ) throws -> [ConfigProperties: Any] {
        guard let configFilePath = configFilePathOpt else {
            return [:]
        }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: configFilePath) {
            throw ConfigsValidationErrors.ConfigFileDoesNotExist(filePath: configFilePath)
        }

        let configFileContent: String
        do {
            configFileContent = try String(contentsOfFile: configFilePath)
        }
        catch {
            throw ConfigsValidationErrors.ConfigFileCannotBeOpened(
                reason: error.localizedDescription)
        }

        let rawConfigs: [String: Any]
        do {
            rawConfigs = try JSONSerialization.jsonObject(
                with: configFileContent.data(using: .utf8)!, options: []) as! [String: Any]
        }
        catch {
            throw ConfigsValidationErrors.ConfigFileCannotBeParsedCorrectly(
                reason: error.localizedDescription)
        }

        var fileConfigs: [ConfigProperties: Any] = [:]
        for (propName, value) in rawConfigs {
            if let configPropName = ConfigProperties(rawValue: propName) {
                fileConfigs[configPropName] = value
            }
            else {
                throw ConfigsValidationErrors.ConfigFileCannotBeParsedCorrectly(
                    reason: "Property \(propName) is not valid (check for typo?)")
            }
        }
        return fileConfigs
    }
}