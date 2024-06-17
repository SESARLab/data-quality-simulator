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
        try! FileUtils.createDirIfNotExist(atPath: self.testDir, withFM: self.fileManager)
    }

    override public func tearDown() {
        try! FileUtils.rmDirIfExists(atPath: self.testDir, withFM: self.fileManager)

        super.tearDown()
    }
    
    // Parameterized tests?
    func testGivenConfigs_whenPropertyIsMissing_thenThrow() throws {
        for prop in ConfigProperties.allCases {
            var configs = SimulatorConfigsFactory.build()
            configs[prop] = nil

            self.logger!.info("Testing for property \(prop.rawValue)")
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

    func testGivenConfigsFromFile_whenPropertyHasWrongType_thenThrow() throws {
        
    }
}