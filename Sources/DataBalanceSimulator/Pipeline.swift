import PythonKit

class Pipeline {
    let services: [BaseService]

    let metricName: String

    init(services: [BaseService], metricName: String) throws {
        guard !services.isEmpty else {
            throw GenericErrors.InvalidState("Pipeline cannot run with 0 services")
        }
        self.services = services
        self.metricName = metricName
    }

    public func run(
        on dataset: PythonObject, 
        withCache cache: [([BaseService], PythonObject)]? = nil
    ) -> (output: PythonObject, statsCalculator: StatsCalculator) {
        let startingDataset: PythonObject
        var previouslyChosenServices: [BaseService]
        let pipelineServices: [BaseService]
        var accumulatedFilteringSeed: [UInt8]
        if let cacheHit = searchForBestCacheHit(on: cache) {
            startingDataset = cacheHit.1
            previouslyChosenServices = cacheHit.0
            pipelineServices = Array(services[cacheHit.0.count...])
            accumulatedFilteringSeed = previouslyChosenServices.flatMap { $0.filteringSeed }
        }
        else {
            startingDataset = dataset
            previouslyChosenServices = []
            pipelineServices = services
            accumulatedFilteringSeed = []
        }

        let output = pipelineServices.reduce(startingDataset, { (res: PythonObject, current: BaseService) -> PythonObject in
            let result = current.run(
                on: res,
                withContext: Context(
                    previouslyChosenServices: previouslyChosenServices,
                    accumulatedFilteringSeed: accumulatedFilteringSeed
                )
            )
            previouslyChosenServices.append(current)
            accumulatedFilteringSeed += current.filteringSeed

            return result
        })

        return (
            output: output, 
            statsCalculator: try! StatsCalculator(
                originalDataset: dataset,
                filteredDataset: output,
                pipeline: self,
                metricName: metricName
            )
        )
    }

    private func searchForBestCacheHit(
        on cache: [([BaseService], PythonObject)]?
    ) -> ([BaseService], PythonObject)? {
        var bestHit: ([BaseService], PythonObject)? = nil

        for (cachedServices, cachedDataset) in (cache ?? []) {
            if cachedServices.isPrefix(of: services) {
                if let foundBestHit = bestHit {
                    if cachedServices.count > foundBestHit.0.count {
                        bestHit = (cachedServices, cachedDataset)
                    }
                }
                else {
                    bestHit = (cachedServices, cachedDataset)
                }
            }
        }

        return bestHit
    }
}