import ArgumentParser
// import PythonKit
// import Rainbow
import Logging
import Foundation

// setupPythonEnvironment()

// let pd = Python.import("pandas")
// let np = Python.import("numpy")
// let dataframe = pd.read_csv("Input/inmates_enriched_10k.csv")
// let lib = Python.import("functions")


/**
The configurations for the simulation run. See parameters in SimulatorOptions
*/
struct SimulatorConfigs {
    var seed: Int
    var minNodes: Int
    var maxNodes: Int
    var minServices: Int
    var maxServices: Int
    var lowerBound: Float
    var upperBound: Float
}

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

    @Option(name: .long, help: "Lower bound")
    var lowerBound: Float?

    @Option(name: .long, help: "Upper bound")
    var upperBound: Float?

    @Option(name: .long, help: """
    Configuration file containing the same properties as the CLI in the format
    ```
    prop1=1
    prop2=2
    ```
    The CLI options can overwrite this configurations
    """)
    var configFile: String?

    private func mergeConfigsFromOptionsAndFile() -> SimulatorConfigs? {
        return nil;
    }

    public func run() throws {
        LoggingSystem.bootstrap(StreamLogHandler.standardError)
        let logger = Logger(label: "SimulatorCLI")
        // logger.info("""
        // Starting with simulator with:")
        //     ├─ seed=\(self.seed)")
        //     ├─ minNodes=\(self.minNodes)")
        //     ├─ maxNodes=\(self.maxNodes)")
        //     ├─ minServices=\(self.minServices)")
        //     ├─ maxServices=\(self.maxServices)")
        //     ├─ minNodes=\(self.minNodes)")
        //     ├─ lowerBound=\(self.lowerBound)")
        //     └─ upperBound=\(self.upperBound)")
        // """)

        // let nodesRange = minNodes...maxNodes
        // let servicesRange = minServices...maxServices


        // lib.lowerBound = PythonObject( lowerBound )
        // lib.upperBound = PythonObject( upperBound )
        // lib.number_of_nodes = PythonObject( numberOfNodes )
        // lib.number_of_services = PythonObject( numberOfServices )

        // EXPERIMENT_SEED = experimentRange

        // print("Starting experiment with seed: \(EXPERIMENT_SEED)".yellow)

        // for numberOfServices in servicesRange {
        //   for numberOfNodes in nodesRange {
        //     let nodes = Array(1...numberOfNodes * numberOfServices)
        //       .map { Service(id: $0) }
        //       .chunked(into: numberOfServices)

        //     print("Starting with \(numberOfNodes) nodes and \(numberOfServices) services".green)

        //     let sim = SimulationWindow(nodes: nodes, dataframe: dataframe)

        //     for windowSize in 1...numberOfNodes {
        //       print("w: \(windowSize): ", terminator: "")
        //       let result = sim.run(windowSize: windowSize)
        //       print("m: \(result.metric) | ma: \(result.metric_average) | %: \(result.percentage)")

        //       lib.store([
        //         "metric": result.metric,
        //         "experiment_id": Double(EXPERIMENT_SEED),
        //         "window_size": result.window_size,
        //         "number_of_nodes": Double(numberOfNodes),
        //         "number_of_services": Double(numberOfServices),
        //         "percentage": result.percentage,
        //         "execution_time": result.execution_time,
        //       ])
        //     }
        //   }
        // }
    }

}