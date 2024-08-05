import ArgumentParser
import PythonKit
import Logging
import Algorithms
import Foundation

@main
struct SimulatorCLI: ParsableCommand {
    @Option(name: .long, help: """
        Seed for sampling. Each service extracts a sample of data; 
        this seed is passed to the service implementation to make the 
        computed sample deterministic (for later inspection)
        """)
    var seed: Int?

    @Option(name: .long, help: "Minimum number of nodes")
    var minNodes: Int?

    @Option(name: .long, help: "Maximum number of nodes")
    var maxNodes: Int?

    @Option(name: .long, help: "Minimum number of services")
    var minServices: Int?

    @Option(name: .long, help: "Maximum number of services")
    var maxServices: Int?

    @Option(name: .long, help: "Maximum window size")
    var maxWindowSize: Int?

    @Option(name: .long, help: """
        Percentage of the minimum number of rows/categories removed after a
        service execution. Its range is [0, 1]
        """)
    var rowLowerBound: Double?

    @Option(name: .long, help: """
        Percentage of the maximum number of rows/categories removed after a
        service execution. Its range is [0, 1]
        """)
    var rowUpperBound: Double?

    @Option(name: .long, help: """
        Percentage of the minimum number of column removed after a
        service execution. Its range is [0, 1]
        """)
    var columnLowerBound: Double?

    @Option(name: .long, help: """
        Percentage of the maximum number of column removed after a
        service execution. Its range is [0, 1]
        """)
    var columnUpperBound: Double?

    @Option(name: .long, help: """
        The metric used to evaluate the best combination of services in the pipeline
        """)
    var metricName: String?

    @Option(name: .long, help: """
        The dataset loaded for the experiment. Available values are the function
        names in the `dataset.py` file
        """)
    var datasetName: String?

    @Option(name: .long, help: """
        The location of the db where execution results are stored 
        """)
    var dbPath: String?

    @Option(name: .long, help: """
        The description of the simulation. It can be useful to distinguish two
        simulations having the same parameters but with different implementations 
        """)
    var description: String?

    @Option(name: .long, help: """
        It specified the filtering type of all services (e.g. only filter rows,
        only filter columns)
        """)
    var filteringType: String?

    @Option(name: .long, help: """
    Configuration file containing the same properties as the CLI in the Json format
    The CLI options can overwrite these configurations
    """)
    var configFilePath: String?

    public func run() throws {
        LoggingSystem.bootstrap(StreamLogHandler.standardError)
        let logger = Logger.createWithLevelFromEnv(fileName: #file)
        let configManager = try ConfigurationManager(simulatorCliConfigs: [
            .seed: seed,
            .minNodes: minNodes,
            .maxNodes: maxNodes,
            .minServices: minServices,
            .maxServices: maxServices,
            .maxWindowSize: maxWindowSize,
            .rowLowerBound: rowLowerBound,
            .rowUpperBound: rowUpperBound,
            .columnLowerBound: columnLowerBound,
            .columnUpperBound: columnUpperBound,
            .metricName: metricName,
            .datasetName: datasetName,
            .dbPath: dbPath,
            .filteringType: filteringType,
            .description: description 
        ], configFilePathOpt: configFilePath)
        logger.log(withDescription: "Starting simulator", withProps: [
            "seed": "\(configManager[.seed])",
            "minNodes": "\(configManager[.minNodes])",
            "maxNodes": "\(configManager[.maxNodes])",
            "minServices": "\(configManager[.minServices])",
            "maxServices": "\(configManager[.maxServices])",
            "maxWindowSize": "\(configManager[.maxWindowSize])",
            "rowLowerBound": "\(configManager[.rowLowerBound])",
            "rowUpperBound": "\(configManager[.rowUpperBound])",
            "columnLowerBound": "\(configManager[.columnLowerBound])",
            "columnUpperBound": "\(configManager[.columnUpperBound])",
            "metricName": "\(configManager[.metricName])",
            "datasetName": "\(configManager[.datasetName])",
            "dbPath": "\(configManager[.dbPath])",
            "filteringType": "\(configManager[.filteringType])",
            "description": "\(configManager[.description])",
        ])

        let execResultsStorage = try ExecResultsStorage(
            dbPath: configManager[.dbPath] as! String
        )

        let nodesRange = (configManager[.minNodes] as! Int)...(configManager[.maxNodes] as! Int)
        let servicesRange = (configManager[.minServices] as! Int)...(configManager[.maxServices] as! Int)
        
        logger.info("Loading the dataset...")
        let dataset = PythonModulesStore.getAttr(
            obj: PythonModulesStore.dataset, 
            attr: configManager[.datasetName] as! String
        )()
        logger.info("Dataset loaded ✅")

        let timeMonitor = TimeMonitor(
            minServices: configManager[.minServices] as! Int, 
            maxServices: configManager[.maxServices] as! Int, 
            minNodes: configManager[.minNodes] as! Int,
            maxNodes: configManager[.maxNodes] as! Int, 
            maxWindowSize: configManager[.maxWindowSize] as! Int
        )
        logger.info("N° of samplings expected: \(timeMonitor.totalSamplings)")

        let allServices = Array(1...(configManager[.maxNodes] as! Int) * (configManager[.maxServices] as! Int))
                    .map { createService(
                        withId: $0, 
                        usingConfigsFrom: configManager
                    ) }
        
        for servicesCount in servicesRange {
            for nodesCount in nodesRange {
                let nodes = allServices.prefix(nodesCount * servicesCount)
                    .chunks(ofCount: servicesCount).map { Array($0) }

                for windowSize in 1...min(nodesCount, configManager[.maxWindowSize] as! Int) {
                    let sim = try Simulation(
                        nodes: nodes, 
                        windowSize: windowSize, 
                        metricName: configManager[.metricName] as! String,
                        timeMonitor: timeMonitor
                    )

                    let simulationResults = try sim.run(on: dataset)

                    try execResultsStorage.insert(ExecutionResults(
                        executionTime: simulationResults.executionTime, 
                        experimentId: configManager[.seed] as! Int, 
                        windowSize: windowSize, 
                        maxNodes: configManager[.maxNodes] as! Int, 
                        nodesCount: nodesCount, 
                        maxServices: configManager[.maxServices] as! Int, 
                        servicesCount: servicesCount,
                        dataset: configManager[.datasetName] as! String,
                        metricName: configManager[.metricName] as! String,
                        metricValue: simulationResults.metricValue, 
                        percentage: simulationResults.percentage, 
                        rowLowerBound: configManager[.rowLowerBound] as! Double, 
                        rowUpperBound: configManager[.rowUpperBound] as! Double,
                        columnLowerBound: configManager[.columnLowerBound] as! Double, 
                        columnUpperBound: configManager[.columnUpperBound] as! Double,
                        description: configManager[.description] as! String,
                        filteringType: configManager[.filteringType] as! FilteringType
                    ))
                }
            }
        }
    }

    private func createService(
        withId id: Int,
        usingConfigsFrom configManager: ConfigurationManager
    ) -> BaseService {
        let filteringType = configManager[.filteringType] as! FilteringType
        switch filteringType {
            case .row: return RowFilterService(
                id: id,
                experimentSeed: configManager[.seed] as! Int,
                rowLowerBound: configManager[.rowLowerBound] as! Double, 
                rowUpperBound: configManager[.rowUpperBound] as! Double
            )
            case .column: return ColumnFilterService(
                id: id,
                experimentSeed: configManager[.seed] as! Int,
                rowLowerBound: configManager[.rowLowerBound] as! Double, 
                rowUpperBound: configManager[.rowUpperBound] as! Double,
                columnLowerBound: configManager[.columnLowerBound] as! Double, 
                columnUpperBound: configManager[.columnUpperBound] as! Double
            )
            case .mixed: return RowAndColumnFilterService(
                id: id,
                experimentSeed: configManager[.seed] as! Int,
                rowLowerBound: configManager[.rowLowerBound] as! Double, 
                rowUpperBound: configManager[.rowUpperBound] as! Double,
                columnLowerBound: configManager[.columnLowerBound] as! Double, 
                columnUpperBound: configManager[.columnUpperBound] as! Double
            )
        }
    }

    struct ExecutionResults {
        let executionTime: Double
        let experimentId: Int
        let windowSize: Int
        let maxNodes: Int
        let nodesCount: Int
        let maxServices: Int
        let servicesCount: Int
        let dataset: String
        let metricName: String
        let metricValue: Double
        let percentage: Double
        let rowLowerBound: Double
        let rowUpperBound: Double
        let columnLowerBound: Double
        let columnUpperBound: Double
        let description: String
        let filteringType: FilteringType
    }
}