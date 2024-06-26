@testable import DataBalanceSimulator

class SimulatorConfigsFactory {
    public static func build() -> [ConfigProperties: LosslessStringConvertible] {
        return [
            ConfigProperties.seed: 1, 
            ConfigProperties.minNodes: 2,
            ConfigProperties.maxNodes: 3,
            ConfigProperties.minServices: 2, 
            ConfigProperties.maxServices: 3, 
            ConfigProperties.lowerBound: 0.1, 
            ConfigProperties.upperBound: 1.0,
            ConfigProperties.metricName: "qualitative",
            ConfigProperties.datasetName: "mydataset"
        ]
    }
}