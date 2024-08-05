@testable import DataBalanceSimulator

class SimulationFactory {
    public static func build(
        withNodes nodes: [[BaseService]], 
        withWindowSize winSize: Int
    ) throws -> Simulation {
        return try Simulation(
            nodes: nodes, windowSize: winSize, metricName: "quantitative",
            timeMonitor: TimeMonitor(
                minServices: 1, maxServices: 1, minNodes: 1, maxNodes: 1, maxWindowSize: 1)
        )
    }
}