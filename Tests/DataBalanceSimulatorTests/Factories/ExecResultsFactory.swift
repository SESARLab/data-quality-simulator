@testable import DataBalanceSimulator

class ExecResultsFactory {
    public static func build() -> SimulatorCLI.ExecutionResults {
        return SimulatorCLI.ExecutionResults(
            executionTime: 1.0, 
            experimentId: 2, 
            windowSize: 3,
            maxNodes: 4,
            nodesCount: 5, 
            maxServices: 6, 
            servicesCount: 7, 
            dataset: "dataset1", 
            metricName: "metric1", 
            metricValue: 8.0, 
            percentage: 0.5, 
            rowLowerBound: 0.1, 
            rowUpperBound: 0.8,
            columnLowerBound: 0.2, 
            columnUpperBound: 0.7,
            description: "test",
            filteringType: .mixed
        )
    }
}