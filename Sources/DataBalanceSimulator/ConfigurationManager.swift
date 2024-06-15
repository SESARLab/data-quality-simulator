import Foundation

enum ConfigsValidationErrors: Error, Equatable {
    case ConfigFileDoesNotExist(filePath: String)
    case ConfigFileCannotBeOpened(reason: String)
    case ConfigFileCannotBeParsedAsJson(reason: String)
    case ConfigPropertyIsNotInitialized(propertyName: String)
    case ConfigPropertyTypeIsNotCompliant(
        propertyName: String, expectedType: String
    )
}

protocol SimulatorConfigs {
    var seed: Int { get }
    var minNodes: Int { get }
    var maxNodes: Int { get }
    var minServices: Int { get }
    var maxServices: Int { get }
    var lowerBound: Float { get }
    var upperBound: Float { get }
}

class ConfigurationManager: SimulatorConfigs {
    var seed: Int

    var minNodes: Int

    var maxNodes: Int

    var minServices: Int

    var maxServices: Int

    var lowerBound: Float

    var upperBound: Float

    init(simulatorCliConfigs: SimulatorCLIConfigs, configFilePathOpt: String?) throws {
        var configs: [String: Any] = try ConfigurationManager.getConfigsFromFile(
            configFilePathOpt: configFilePathOpt)

        try ConfigurationManager.updateConfigsWithCLIOptions(
            configs: &configs, simulatorCliConfigs: simulatorCliConfigs
        )
        
        self.seed = try ConfigurationManager.castConfigProp(
            propType: Int.self, configs: configs, propName: "seed"
        )
        self.minNodes = try ConfigurationManager.castConfigProp(
            propType: Int.self, configs: configs, propName: "minNodes"
        )
        self.maxNodes = try ConfigurationManager.castConfigProp(
            propType: Int.self, configs: configs, propName: "maxNodes"
        )
        self.minServices = try ConfigurationManager.castConfigProp(
            propType: Int.self, configs: configs, propName: "minServices"
        )
        self.maxServices = try ConfigurationManager.castConfigProp(
            propType: Int.self, configs: configs, propName: "maxServices"
        )
        self.lowerBound = try ConfigurationManager.castConfigProp(
            propType: Float.self, configs: configs, propName: "lowerBound"
        )
        self.upperBound = try ConfigurationManager.castConfigProp(
            propType: Float.self, configs: configs, propName: "upperBound"
        )
    }

    private static func updateConfigsWithCLIOptions(
        configs: inout [String: Any], simulatorCliConfigs: SimulatorCLIConfigs
    ) throws {
        configs["seed"] = try mergeValuesForSameConfig(forProp: "seed", 
            values: configs["seed"], simulatorCliConfigs.seed)
        configs["minNodes"] = try mergeValuesForSameConfig(forProp: "minNodes", 
            values: configs["minNodes"], simulatorCliConfigs.minNodes)
        configs["maxNodes"] = try mergeValuesForSameConfig(forProp: "maxNodes", 
            values: configs["maxNodes"], simulatorCliConfigs.maxNodes)
        configs["minServices"] = try mergeValuesForSameConfig(forProp: "minServices", 
            values: configs["minServices"], simulatorCliConfigs.minServices)
        configs["maxServices"] = try mergeValuesForSameConfig(forProp: "maxServices", 
            values: configs["maxServices"], simulatorCliConfigs.maxServices)
        configs["lowerBound"] = try mergeValuesForSameConfig(forProp: "lowerBound", 
            values: configs["lowerBound"], simulatorCliConfigs.lowerBound)
        configs["upperBound"] = try mergeValuesForSameConfig(forProp: "upperBound", 
            values: configs["upperBound"], simulatorCliConfigs.upperBound)
    }

    private static func castConfigProp<T>(
        propType: T.Type, configs: [String: Any], propName: String
    ) throws -> T {
        guard let castProp = configs[propName] as? T else {
            throw ConfigsValidationErrors.ConfigPropertyTypeIsNotCompliant(
                propertyName: propName, expectedType: String(describing: propType))
        }
        return castProp
    }

    private static func mergeValuesForSameConfig<T>(forProp: String, values: T...) throws -> T {
        if let configValue = values.reversed().compactMap({ $0 }).first {
            return configValue
        } else {
            throw ConfigsValidationErrors.ConfigPropertyIsNotInitialized(
                propertyName: forProp)
        }
    }

    private static func getConfigsFromFile(
        configFilePathOpt: String?
    ) throws -> [String: Any] {
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

        do {
            let configs = try JSONSerialization.jsonObject(
                with: configFileContent.data(using: .utf8)!, options: []) as! [String: Any]
            return configs;
        }
        catch {
            throw ConfigsValidationErrors.ConfigFileCannotBeParsedAsJson(
                reason: error.localizedDescription)
        }
    }
}