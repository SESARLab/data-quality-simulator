@testable import DataBalanceSimulator

class PipelineFactory {
    public static func build(withServices services: [SimpleService]) throws -> Pipeline {
        return try Pipeline(services: services, metricName: MetricNames.qualitative)
    }
}