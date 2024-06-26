import Logging

import XCTest
@testable import DataBalanceSimulator

public class ConfigurationManagerTests: XCTestCase {
    var logger: Logger? = nil
    var fileManager = FileManager.default
    let testDir = "./test_files"

    override public func setUp() {
        super.setUp()

        self.logger = Logger(label: String(describing: self))
        self.logger!.logLevel = .debug
        try! FileUtils.createDirIfNotExist(atPath: self.testDir, withFM: self.fileManager)
    }

    override public func tearDown() {
        try! FileUtils.rmDirIfExists(atPath: self.testDir, withFM: self.fileManager)

        super.tearDown()
    }

    func testGivenValidConfigsFromCli_thenOk() throws {
        let configs = SimulatorConfigsFactory.build()

        let configManager = try ConfigurationManager(
            simulatorCliConfigs: configs, 
            configFilePathOpt: nil
        )

        for prop in ConfigProperties.allCases {
            XCTAssertEqual(configs[prop]!.description, configManager[prop].description)
        }
    }

    func testGivenValidConfigsFromFile_thenOk() throws {
        let configFilePath = "\(testDir)/valid_config.json"
        let configs = SimulatorConfigsFactory.build()
        FileUtils.createConfigFile(
            withProps: Dictionary(uniqueKeysWithValues: configs.map { ($0.rawValue, $1) }), 
            atPath: configFilePath,
            withFM: fileManager)

        let configManager = try ConfigurationManager(
            simulatorCliConfigs: [:], 
            configFilePathOpt: configFilePath
        )

        for prop in ConfigProperties.allCases {
            XCTAssertEqual(configs[prop]!.description, configManager[prop].description)
        }
    }

    func testGivenValidConfigsFromCliAndFile_whenMergeThem_thenCliOverwriteFile() throws {
        let configFilePath = "\(testDir)/valid_config.json"
        let fileConfigs = SimulatorConfigsFactory.build()
        FileUtils.createConfigFile(
            withProps: Dictionary(uniqueKeysWithValues: fileConfigs.map { ($0.rawValue, $1) }), 
            atPath: configFilePath,
            withFM: fileManager)
        let cliSeed = (fileConfigs[.seed] as! Int) + 1
        let cliConfigs = [
            ConfigProperties.seed: cliSeed
        ]

        let configManager = try ConfigurationManager(
            simulatorCliConfigs: cliConfigs, 
            configFilePathOpt: configFilePath
        )

        for prop in ConfigProperties.allCases {
            if prop == .seed {
                XCTAssertEqual(cliSeed, configManager[.seed] as! Int)
            }
            else {
                XCTAssertEqual(fileConfigs[prop]!.description, configManager[prop].description)
            }
        }
    }
    
    // Parameterized tests?
    func testGivenConfigs_whenPropertyIsMissing_thenThrow() throws {
        for prop in ConfigProperties.allCases {
            var configs = SimulatorConfigsFactory.build()
            configs[prop] = nil

            TestUtils.logParameterize(forFunction: #function, withInput: prop.rawValue, logger: self.logger!)
            XCTAssertThrowsError(
                try ConfigurationManager(
                    simulatorCliConfigs: configs, 
                    configFilePathOpt: nil
                ), "\(prop.rawValue) is not initialized", { error in
                    XCTAssertEqual(
                        error as? ConfigsValidationErrors, 
                        ConfigsValidationErrors.ConfigPropertyIsNotInitialized(property: prop)
                    )
                }
            )
        }
    }

    func testGivenConfigsFromFile_whenFileDoesNotExist_thenThrow() throws {
        let fakeFilePath = "./I-DO-NOT-EXIST.json"
        XCTAssertThrowsError(
            try ConfigurationManager(
                simulatorCliConfigs: [:], 
                configFilePathOpt: fakeFilePath
            ), "File does not exist", { error in
                XCTAssertEqual(
                    error as? ConfigsValidationErrors, 
                    ConfigsValidationErrors.ConfigFileDoesNotExist(filePath: fakeFilePath)
                )
            }
        )
    }

    func testGivenConfigsFromFile_whenFileIsNotValid_thenThrow() throws {
        let filePath = "\(testDir)/invalid-config.json"
        fileManager.createFile(atPath: filePath, contents: "{\"notExistingProperty\": 1}".data(using: .utf8))

        XCTAssertThrowsError(
            try ConfigurationManager(
                simulatorCliConfigs: [:], 
                configFilePathOpt: filePath
            ), "File cannot be converted to correct configurations", { error in
                XCTAssertEqual(
                    error as? ConfigsValidationErrors, 
                    ConfigsValidationErrors.ConfigFileCannotBeParsedCorrectly(
                        reason: "Property notExistingProperty is not valid (check for typo?)"
                    )
                )
            }
        )
    }

    struct NotExistingType: LosslessStringConvertible {
        init?(_ description: String) {
            self.description = description
        }

        var description: String
    }
    
    func testGivenConfigsFromCli_whenPropertyHasWrongType_thenThrow() throws {
        for prop in ConfigProperties.allCases {
            var configs = SimulatorConfigsFactory.build()
            configs[prop] = NotExistingType("does-not-exist")

            TestUtils.logParameterize(forFunction: #function, withInput: prop.rawValue, logger: self.logger!)
            XCTAssertThrowsError(
                try ConfigurationManager(
                    simulatorCliConfigs: configs, 
                    configFilePathOpt: nil
                ), "type of \(prop.rawValue) is not correct", { error in
                    XCTAssertEqual(
                        error as? ConfigsValidationErrors, 
                        ConfigsValidationErrors.ConfigPropertyTypeIsNotCompliant(property: prop)
                    )
                }
            )
        }
    }
}