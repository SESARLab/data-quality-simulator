import Logging

import XCTest
@testable import DataBalanceSimulator

public class ConfigurationManagerTests: XCTestCase {
    var logger: Logger? = nil
    var fileManager = FileManager.default
    let testConfigsDir = "./test_files/configs"

    override public func setUp() {
        super.setUp()

        self.logger = Logger(label: String(describing: self))
        try! FileUtils.createDirIfNotExist(atPath: self.testConfigsDir, withFM: self.fileManager)
    }

    override public func tearDown() {
        try! FileUtils.rmDirIfExists(atPath: self.testConfigsDir, withFM: self.fileManager)

        super.tearDown()
    }
    
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
                        error as! ConfigsValidationErrors, 
                        ConfigsValidationErrors.ConfigPropertyIsNotInitialized(property: prop)
                    )
                }
            )
        }
    }

    func testGivenConfigsFromFile_whenPropertyHasWrongType_thenThrow() throws {
        
    }
}