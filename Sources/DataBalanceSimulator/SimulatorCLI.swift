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
    Configuration file containing the same properties as the CLI in the Json format
    The CLI options can overwrite these configurations
    """)
    var configFilePath: String?

    public func run() throws {
        LoggingSystem.bootstrap(StreamLogHandler.standardError)
        let logger = Logger(label: #file.getFileName())
        let configManager = try ConfigurationManager(simulatorCliConfigs: [
            .seed: seed,
            .minNodes: minNodes,
            .maxNodes: maxNodes,
            .minServices: minServices,
            .maxServices: maxServices,
            .lowerBound: lowerBound,
            .upperBound: upperBound,
            .metricName: metricName,
            .datasetName: datasetName
        ], configFilePathOpt: configFilePath)
        logger.info("""
        Starting with simulator with:
            ├─ seed=\(configManager[.seed])
            ├─ minNodes=\(configManager[.minNodes])
            ├─ maxNodes=\(configManager[.maxNodes])
            ├─ minServices=\(configManager[.minServices])
            ├─ maxServices=\(configManager[.maxServices])
            ├─ minNodes=\(configManager[.minNodes])
            ├─ lowerBound=\(configManager[.lowerBound])
            ├─ upperBound=\(configManager[.upperBound])
            ├─ metricName=\(configManager[.metricName])
            └─ datasetName=\(configManager[.datasetName])
        """)

        let nodesRange = (configManager[.minNodes] as! Int)...(configManager[.maxNodes] as! Int)
        let servicesRange = (configManager[.minServices] as! Int)...(configManager[.maxServices] as! Int)
        let dataset = PythonModulesStore.getAttr(
            module: PythonModulesStore.dataset, 
            attr: configManager[.datasetName] as! String
        )()

        for numberOfServices in servicesRange {
            for numberOfNodes in nodesRange {
                let nodes = Array(1...numberOfNodes * numberOfServices)
                    .map { SimpleService(
                        id: $0, 
                        experimentSeed: configManager[.seed] as! Int,
                        filterLowerBound: configManager[.lowerBound] as! Double, 
                        filterUpperBound: configManager[.upperBound] as! Double
                    ) }
                    .chunks(ofCount: numberOfServices).map { Array($0) }

                for windowSize in 1...numberOfNodes {
                    let sim = try Simulation(
                        nodes: nodes, 
                        windowSize: windowSize, 
                        metricName: configManager[.metricName] as! String
                    )

                    try sim.run(on: dataset)
        //         lib.store([
        //             "metric": result.metric,
        //             "experiment_id": Double(EXPERIMENT_SEED),
        //             "window_size": result.window_size,
        //             "number_of_nodes": Double(numberOfNodes),
        //             "number_of_services": Double(numberOfServices),
        //             "percentage": result.percentage,
        //             "execution_time": result.execution_time,
        //         ])
                }
            }
        }
    }
}