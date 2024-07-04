@testable import DataBalanceSimulator

class PipelineFactory {
    public static func build(withServices services: [BaseService]) throws -> Pipeline {
        return try Pipeline(services: services, metricName: "quantitative")
    }
}