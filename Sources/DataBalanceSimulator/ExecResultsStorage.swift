import SQLite
import Foundation
import Logging

class ExecResultsStorage {
    let db: Connection
    let logger: Logger

    static let table = Table("results")
    static let CONN_ERROR_MAX_RETRIES = 8

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
        self.logger = Logger.createWithLevelFromEnv(fileName: #file)
        logger.debug("Connecting to the database...")
        self.db = try Connection(dbPath)
        logger.debug("Connected to the database ✅")
    }

    public func insert(_ execResults: SimulatorCLI.ExecutionResults) throws {
        var retryDelay: Double = 0.5
        for retryAttempt in 0..<ExecResultsStorage.CONN_ERROR_MAX_RETRIES {
            do {
                logger.info("Trying to insert execution results into database... (Attempt n. \(retryAttempt))")
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
                logger.info("Insert of execution results successful ✅")

                return
            }
            catch {
                logger.info("Insert of execution results failed ❌")
                logger.info("Error: \(error.localizedDescription)")
                logger.info("Retrying with exponential backoff...")
                
                let randomDelayFactor = Double.random(in: 0...1)
                retryDelay = (retryDelay * 2) + randomDelayFactor
                Thread.sleep(forTimeInterval: retryDelay)
            }
        }

        throw GenericErrors.Timeout("Reached maximum retry attempts while inserting execution results into db")
    }

}