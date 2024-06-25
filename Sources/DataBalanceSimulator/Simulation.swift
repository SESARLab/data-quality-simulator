import PythonKit

class Simulation {
    let nodes: [[SimpleService]]

    let windowSize: Int

    let metricName: MetricNames

    init(
        nodes: [[SimpleService]], 
        windowSize: Int,
        metricName: MetricNames
    ) {
        self.nodes = nodes
        self.windowSize = windowSize
        self.metricName = metricName
    }

    public func run(on data: PythonObject) throws -> Result {
        let windows = nodes.windows(ofCount: windowSize)
        var previouslyChosenServices: [SimpleService] = []
        var pipelineCache: [([SimpleService], PythonObject)] = []
        let originalDataset = data

        for (index, window) in windows.enumerated() {
            // var currentBest: Simulation.Result?

            for servicesCombination in Array(window).cartesianProduct() {
                let pipeline = try Pipeline(
                    services: previouslyChosenServices + servicesCombination, 
                    metricName: metricName
                )

                let output = pipeline.run(on: originalDataset, withCache: pipelineCache)
                // let possibleBest = sim.run(services: servicesCombination)

        //         // print("weight:", choosedServices, combination, hash((choosedServices + combination).flatMap { $0.weight }))
        //         // print(choosedServices, combination, possibleBest.metric)

                // if let _currentBest = currentBest {
                //     // print("best:", _currentBest.metric, possibleBest.metric)
                //     currentBest = best(r1: _currentBest, r2: possibleBest)
                //     // print("best:", _currentBest.metric, possibleBest.metric, currentBest!.metric)
                // } else {
                //     currentBest = possibleBest
                // }
            }

            // print("current best:", choosedServices, currentBest!.metric, currentBest!.services)
            if index == windows.count - 1 {
                // previouslyChosenServices += currentBest!.services
            } 
            else {
                // previouslyChosenServices.append(currentBest!.services.first!)
            }

            let pipelineForChosen = try Pipeline(services: previouslyChosenServices, metricName: metricName)
            let (filteredDataset, metrics) = pipelineForChosen.run(on: originalDataset, withCache: pipelineCache)
            pipelineCache = [(previouslyChosenServices, filteredDataset)]
            
        //     result = Simulation(dataframe: dataframe, original: dataframe).run(services: choosedServices)
        //     // print("fine:", choosedServices, result!.metric)
        }

        // print("\(result!.services)".red)

        // let endTime = DispatchTime.now()
        // let executionTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0

        return Result(
            metric: 0.0, 
            metric_average: 0.0,
            window_size: 0,
            percentage: 0.0,
            execution_time: 0.0
        )
    }

    struct Result {
        let metric: Double
        let metric_average: Double
        let window_size: Double
        let percentage: Double
        let execution_time: Double
    }
}