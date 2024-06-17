import Logging

import XCTest
@testable import DataBalanceSimulator

struct SimulatorConfigs: SimulatorCLIConfigs {
    var seed: Int?
    var minNodes: Int?
    var maxNodes: Int?
    var minServices: Int?
    var maxServices: Int?
    var lowerBound: Float?
    var upperBound: Float?
}


public class ConfigurationManagerTests: XCTestCase {
    var logger: Logger? = nil

    override public func setUp() {
        super.setUp()
        self.logger = Logger(label: String(describing: self))
    }
    
    func testGivenConfigsFromCli_whenPropertyIsMissing_thenThrow() throws {
        var simulatorConfigs = SimulatorConfigsFactory.build()
        simulatorConfigs.seed = nil

        let testInputs = [
            (propName: "seed", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.seed = nil
                return configs
            }),
            (propName: "minNodes", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.minNodes = nil
                return configs
            }),
            (propName: "maxNodes", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.maxNodes = nil
                return configs
            }),
            (propName: "minServices", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.minServices = nil
                return configs
            }),
            (propName: "maxServices", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.maxServices = nil
                return configs
            }),
            (propName: "lowerBound", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.lowerBound = nil
                return configs
            }),
            (propName: "upperBound", simulatorSupplier: { 
                var configs = SimulatorConfigsFactory.build()
                configs.upperBound = nil
                return configs
            }),
        ]

        for (propName, simulatorSupplier) in testInputs {
            self.logger!.info("Testing for property \(propName)")
            let simulatorConfigs = simulatorSupplier()
            XCTAssertThrowsError(
                try ConfigurationManager(
                    simulatorCliConfigs: simulatorConfigs, 
                    configFilePathOpt: nil
                ), "seed is not initialized", { error in
                    XCTAssertEqual(
                        error as! ConfigsValidationErrors, 
                        ConfigsValidationErrors.ConfigPropertyIsNotInitialized(propertyName: propName)
                    )
                }
            )
        }
    }
}