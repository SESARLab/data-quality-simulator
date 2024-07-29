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

enum FilteringType: String, LosslessStringConvertible {
    case row
    case column
    case mixed

    var description: String {
        return self.rawValue
    }

    init?(_ description: String) {
        self.init(rawValue: description)
    }
}

enum ConfigProperties: String, CaseIterable {
    case seed
    case minNodes
    case maxNodes
    case minServices
    case maxServices
    case maxWindowSize
    case rowLowerBound
    case rowUpperBound
    case columnLowerBound
    case columnUpperBound
    case metricName
    case datasetName
    case dbPath
    case description
    case filteringType

    func castToActualType(value: LosslessStringConvertible) -> LosslessStringConvertible? {
        switch self {
            case .seed: return Int("\(value)")
            case .minNodes: return Int("\(value)")
            case .maxNodes: return Int("\(value)")
            case .minServices: return Int("\(value)")
            case .maxServices: return Int("\(value)")
            case .maxWindowSize: return Int("\(value)")
            case .rowLowerBound: return Double("\(value)")
            case .rowUpperBound: return Double("\(value)")
            case .columnLowerBound: return Double("\(value)")
            case .columnUpperBound: return Double("\(value)")
            case .metricName: return value
            case .datasetName: return value
            case .dbPath: return value
            case .description: return value
            case .filteringType: return FilteringType(rawValue: "\(value)")
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
            guard let castProp = prop.castToActualType(value: self.configs[prop]!) else {
                throw ConfigsValidationErrors.ConfigPropertyTypeIsNotCompliant(property: prop)
            }

            configs[prop] = castProp
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
                    case .maxWindowSize: Int("\(value)")
                    case .rowLowerBound: Double("\(value)")
                    case .rowUpperBound: Double("\(value)")
                    case .columnLowerBound: Double("\(value)")
                    case .columnUpperBound: Double("\(value)")
                    case .metricName: String(describing: value)
                    case .datasetName: String(describing: value)
                    case .dbPath: String(describing: value)
                    case .description: String(describing: value)
                    case .filteringType: String(describing: value)
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