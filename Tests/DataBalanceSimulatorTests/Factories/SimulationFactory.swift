@testable import DataBalanceSimulator

class SimulationFactory {
    public static func build(
        withNodes nodes: [[BaseService]], 
        withWindowSize winSize: Int
    ) throws -> Simulation {
        return try Simulation(
            nodes: nodes, windowSize: winSize, metricName: "quantitative"
        )
    }
}