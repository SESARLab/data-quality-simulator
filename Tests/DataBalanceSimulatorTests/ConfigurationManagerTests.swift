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
    func testgivenConfigsFromCli_whenPropertyIsMissing_thenThrow() throws {
        var simulatorConfigs = SimulatorConfigsFactory.build()
        simulatorConfigs.seed = nil
        
        XCTAssertThrowsError(
            try ConfigurationManager(
                simulatorCliConfigs: simulatorConfigs, 
                configFilePathOpt: nil
            ), "seed is not initialized", { error in
                XCTAssertEqual(
                    error as! ConfigsValidationErrors, 
                    ConfigsValidationErrors.ConfigPropertyIsNotInitialized(propertyName: "seed")
                )
            }
        )
    }
}