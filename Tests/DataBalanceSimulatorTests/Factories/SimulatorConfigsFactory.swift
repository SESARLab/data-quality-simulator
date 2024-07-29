@testable import DataBalanceSimulator

class SimulatorConfigsFactory {
    public static func build() -> [ConfigProperties: LosslessStringConvertible] {
        return [
            .seed: 1, 
            .minNodes: 2,
            .maxNodes: 3,
            .minServices: 2, 
            .maxServices: 3,
            .maxWindowSize: 2,
            .rowLowerBound: 0.1, 
            .rowUpperBound: 1.0,
            .columnLowerBound: 0.1, 
            .columnUpperBound: 1.0,
            .metricName: "qualitative",
            .datasetName: "mydataset",
            .dbPath: "mydb",
            .description: "test",
            .filteringType: "row"
        ]
    }
}