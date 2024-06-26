import PythonKit
import Foundation

class Simulation {
    let nodes: [[SimpleService]]

    let windowSize: Int

    let metricName: MetricNames

    init(
        nodes: [[SimpleService]],
        windowSize: Int,
        metricName: MetricNames
    ) throws {
        guard nodes.count >= windowSize else {
            throw GenericErrors.InvalidState("windowSize must be smaller than the number of nodes")
        }

        self.nodes = nodes
        self.windowSize = windowSize
        self.metricName = metricName
    }

    public func run(on data: PythonObject) throws -> Result {
        let startTime = DispatchTime.now()
        let result = try internalRun(on: data)
        let endTime = DispatchTime.now()

        let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        
        return Result(
            metric: result.metricValue, 
            percentage: result.filteredPercent, 
            execution_time: Double(elapsedTime) / 1_000_000_000
        )
    }

    private func internalRun(on data: PythonObject) throws -> StatsCalculator {
        let windows = nodes.windows(ofCount: windowSize)
        var previouslyChosenServices: [SimpleService] = []
        var pipelineCache: [([SimpleService], PythonObject)] = []
        let originalDataset = data
        var bestStats: StatsCalculator? = nil

        for (index, window) in windows.enumerated() {
            var bestServiceComb: (services: [SimpleService], stats: StatsCalculator)?

            for servicesCombination in Array(window).cartesianProduct() {
                let pipeline = try Pipeline(
                    services: previouslyChosenServices + servicesCombination, 
                    metricName: metricName
                )

                let pipelineExecution = pipeline.run(on: originalDataset, withCache: pipelineCache)

                if let unwrappedBestComb = bestServiceComb {
                    if pipelineExecution.statsCalculator.metricValue > unwrappedBestComb.stats.metricValue {
                        bestServiceComb = (services: servicesCombination, stats: pipelineExecution.statsCalculator)
                    }
                } 
                else {
                    bestServiceComb = (services: servicesCombination, stats: pipelineExecution.statsCalculator)
                }
            }

            if index == windows.count - 1 {
                previouslyChosenServices += bestServiceComb!.services
            } 
            else {
                previouslyChosenServices.append(bestServiceComb!.services.first!)
            }

            let pipelineForChosen = try Pipeline(services: previouslyChosenServices, metricName: metricName)
            let (filteredDataset, metrics) = pipelineForChosen.run(on: originalDataset, withCache: pipelineCache)
            pipelineCache = [(previouslyChosenServices, filteredDataset)]
            bestStats = metrics
        }

        return bestStats!
    }

    struct Result {
        let metric: Double
        let percentage: Double
        let execution_time: Double
    }
}