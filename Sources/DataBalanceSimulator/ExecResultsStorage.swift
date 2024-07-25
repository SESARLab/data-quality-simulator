import SQLite

class ExecResultsStorage {
    let db: Connection
    static let table = Table("results")

    static let executionTime = Expression<Double>("execution_time")
    static let experimentId = Expression<Int>("experiment_id")
    static let windowSize = Expression<Int>("window_size")
    static let maxNodes = Expression<Int>("max_nodes")
    static let nodesCount = Expression<Int>("nodes_count")
    static let maxServices = Expression<Int>("max_services")
    static let servicesCount = Expression<Int>("services_count")
    static let dataset = Expression<String>("dataset") 
    static let metricName = Expression<String>("metric_name") 
    static let metricValue = Expression<Double>("metric_value")
    static let percentage = Expression<Double>("percentage")
    static let rowLowerBound = Expression<Double>("row_lower_bound")
    static let rowUpperBound = Expression<Double>("row_upper_bound")
    static let columnLowerBound = Expression<Double>("column_lower_bound")
    static let columnUpperBound = Expression<Double>("column_upper_bound")
    static let description = Expression<String>("description")
    static let filteringType = Expression<String>("filtering_type")

    init(dbPath: String) throws {
        self.db = try Connection(dbPath)
    }

    public func insert(_ execResults: SimulatorCLI.ExecutionResults) throws {
        try self.db.run(ExecResultsStorage.table.insert(
            ExecResultsStorage.executionTime <- execResults.executionTime,
            ExecResultsStorage.experimentId <- execResults.experimentId,
            ExecResultsStorage.windowSize <- execResults.windowSize,
            ExecResultsStorage.maxNodes <- execResults.maxNodes,
            ExecResultsStorage.nodesCount <- execResults.nodesCount,
            ExecResultsStorage.maxServices <- execResults.maxServices,
            ExecResultsStorage.servicesCount <- execResults.servicesCount,
            ExecResultsStorage.dataset <- execResults.dataset,
            ExecResultsStorage.metricName <- execResults.metricName,
            ExecResultsStorage.metricValue <- execResults.metricValue,
            ExecResultsStorage.percentage <- execResults.percentage,
            ExecResultsStorage.rowLowerBound <- execResults.rowLowerBound,
            ExecResultsStorage.rowUpperBound <- execResults.rowUpperBound,
            ExecResultsStorage.columnLowerBound <- execResults.columnLowerBound,
            ExecResultsStorage.columnUpperBound <- execResults.columnUpperBound,
            ExecResultsStorage.description <- execResults.description,
            ExecResultsStorage.filteringType <- execResults.filteringType.rawValue
        ))
    }

}