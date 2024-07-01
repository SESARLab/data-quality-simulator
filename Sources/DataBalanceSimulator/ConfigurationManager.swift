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
    case metricName
    case datasetName
    case dbPath

    func isTypeCompatibleWith(value: LosslessStringConvertible) -> Bool {
        switch self {
            case .seed: return Int("\(value)") != nil
            case .minNodes: return Int("\(value)") != nil
            case .maxNodes: return Int("\(value)") != nil
            case .minServices: return Int("\(value)") != nil
            case .maxServices: return Int("\(value)") != nil
            case .lowerBound: return Double("\(value)") != nil
            case .upperBound: return Double("\(value)") != nil
            case .metricName: return value is String
            case .datasetName: return value is String
            case .dbPath: return value is String
        }
    }
}

class ConfigurationManager {
    var configs: [ConfigProperties: LosslessStringConvertible]

    init(simulatorCliConfigs: [ConfigProperties: LosslessStringConvertible?], configFilePathOpt: String?) throws {
        self.configs = try ConfigurationManager.getConfigsFromFile(
            configFilePathOpt: configFilePathOpt)

        try self.mergeConfigsWithCLIOptions(simulatorCliConfigs: simulatorCliConfigs)

        try self.checkTypeOfConfigProperties()
    }

    subscript(prop: ConfigProperties) -> LosslessStringConvertible {
        precondition(configs.count == ConfigProperties.allCases.count)
        
        return self.configs[prop]!
    }

    private func checkTypeOfConfigProperties() throws {
        precondition(configs.count == ConfigProperties.allCases.count)

        for prop in ConfigProperties.allCases {
            guard prop.isTypeCompatibleWith(value: self.configs[prop]!) else {
                throw ConfigsValidationErrors.ConfigPropertyTypeIsNotCompliant(property: prop)
            }
        }
    }

    private func mergeConfigsWithCLIOptions(
        simulatorCliConfigs: [ConfigProperties: LosslessStringConvertible?]
    ) throws {
        for prop in ConfigProperties.allCases {
            self.configs[prop] = try mergeValuesForSameConfig(
                forProp: prop, 
                values: configs[prop], simulatorCliConfigs[prop] ?? nil
            )
        }

        assert(self.configs.count == ConfigProperties.allCases.count)
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
    ) throws -> [ConfigProperties: LosslessStringConvertible] {
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

        var fileConfigs: [ConfigProperties: LosslessStringConvertible] = [:]
        for (propName, value) in rawConfigs {
            if let configPropName = ConfigProperties(rawValue: propName) {
                let castValue: LosslessStringConvertible? = switch configPropName {
                    case .seed: Int("\(value)")
                    case .minNodes: Int("\(value)")
                    case .maxNodes: Int("\(value)")
                    case .minServices: Int("\(value)")
                    case .maxServices: Int("\(value)")
                    case .lowerBound: Double("\(value)")
                    case .upperBound: Double("\(value)")
                    case .metricName: String(describing: value)
                    case .datasetName: String(describing: value)
                    case .dbPath: String(describing: value)
                }

                if castValue != nil {
                    fileConfigs[configPropName] = castValue
                }
            }
            else {
                throw ConfigsValidationErrors.ConfigFileCannotBeParsedCorrectly(
                    reason: "Property \(propName) is not valid (check for typo?)")
            }
        }
        return fileConfigs
    }
}