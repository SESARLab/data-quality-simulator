import PythonKit

class Simulation {
    let nodes: [[SimpleService]]

    let windowSize: Int

    init(nodes: [[SimpleService]], windowSize: Int) {
        self.nodes = nodes
        self.windowSize = windowSize
    }

    public func run(on data: PythonObject) -> Result {
        // let windows = nodes.windows(ofCount: windowSize)
        // var previouslyChosenServices: [SimpleService] = []
        // var serviceContext = SimpleContext(previouslyChosenServices: previouslyChosenServices)

        // for (index, window) in windows.enumerated() {
        //     var currentBest: Simulation.Result?

        //     for servicesCombination in Array(window).cartesianProduct() {
        //         let possibleBest = sim.run(services: combination)

        //         // print("weight:", choosedServices, combination, hash((choosedServices + combination).flatMap { $0.weight }))
        //         // print(choosedServices, combination, possibleBest.metric)

        //         if let _currentBest = currentBest {
        //         // print("best:", _currentBest.metric, possibleBest.metric)
        //         currentBest = best(r1: _currentBest, r2: possibleBest)
        //         // print("best:", _currentBest.metric, possibleBest.metric, currentBest!.metric)
        //         } else {
        //         currentBest = possibleBest
        //         }
        //     }

        //     // print("current best:", choosedServices, currentBest!.metric, currentBest!.services)
        //     if index == nodes.windows(ofCount: windowSize).count - 1 {
        //         choosedServices += currentBest!.services
        //     } else {
        //         choosedServices.append(currentBest!.services.first!)
        //     }
            
        //     result = Simulation(dataframe: dataframe, original: dataframe).run(services: choosedServices)
        //     // print("fine:", choosedServices, result!.metric)
        // }

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