import ArgumentParser
// import Rainbow
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

    @Option(name: .long, help: """
        Percentage of the minimum amount of data removed after a
        service execution. Its range is [0, 1]
        """)
    var lowerBound: Double?

    @Option(name: .long, help: """
        Percentage of the maximum amount of data removed after a
        service execution. Its range is [0, 1]
        """)
    var upperBound: Double?

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
            .lowerBound: lowerBound,
            .upperBound: upperBound,
            .metricName: metricName,
            .datasetName: datasetName,
            .dbPath: dbPath
        ], configFilePathOpt: configFilePath)
        logger.log(withDescription: "Starting simulator", withProps: [
            "seed": "\(configManager[.seed])",
            "minNodes": "\(configManager[.minNodes])",
            "maxNodes": "\(configManager[.maxNodes])",
            "minServices": "\(configManager[.minServices])",
            "maxServices": "\(configManager[.maxServices])",
            "lowerBound": "\(configManager[.lowerBound])",
            "upperBound": "\(configManager[.upperBound])",
            "metricName": "\(configManager[.metricName])",
            "datasetName": "\(configManager[.datasetName])",
            "dbPath": "\(configManager[.dbPath])"
        ])

        logger.debug("Connecting to the database...")
        let execResultsStorage = try ExecResultsStorage(
            dbPath: configManager[.dbPath] as! String
        )
        logger.debug("Connected to the database ✅")

        let nodesRange = (configManager[.minNodes] as! Int)...(configManager[.maxNodes] as! Int)
        let servicesRange = (configManager[.minServices] as! Int)...(configManager[.maxServices] as! Int)
        
        logger.debug("Loading the dataset...")
        let dataset = PythonModulesStore.getAttr(
            obj: PythonModulesStore.dataset, 
            attr: configManager[.datasetName] as! String
        )()
        logger.debug("Dataset loaded ✅")

        let experimentSeed = configManager[.seed] as! Int
        for servicesCount in servicesRange {
            for nodesCount in nodesRange {
                let nodes = Array(1...nodesCount * servicesCount)
                    .map { RowFilterService(
                        id: $0,
                        experimentSeed: experimentSeed,
                        filterLowerBound: configManager[.lowerBound] as! Double, 
                        filterUpperBound: configManager[.upperBound] as! Double
                    ) }
                    .chunks(ofCount: servicesCount).map { Array($0) }

                for windowSize in 1...nodesCount {
                    let sim = try Simulation(
                        nodes: nodes, 
                        windowSize: windowSize, 
                        metricName: configManager[.metricName] as! String
                    )

                    let simulationResults = try sim.run(on: dataset)

                    logger.debug("Insert of execution data into database...")
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
                        lowerBound: configManager[.lowerBound] as! Double, 
                        upperBound: configManager[.upperBound] as! Double
                    ))
                    logger.debug("Insert of execution data successful ✅")
                }
            }
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
        let lowerBound: Double
        let upperBound: Double
    }
}