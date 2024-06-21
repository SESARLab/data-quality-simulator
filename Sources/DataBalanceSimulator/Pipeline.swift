import PythonKit

class Pipeline {
    let services: [SimpleService]

    init(services: [SimpleService]) throws {
        guard !services.isEmpty else {
            throw GenericErrors.InvalidState("Pipeline cannot run with 0 services")
        }
        self.services = services
    }

    public func run(on dataset: PythonObject, withCache cache: [([SimpleService], PythonObject)]? = nil) -> PythonObject {
        let startingDataset: PythonObject
        var previouslyChosenServices: [SimpleService]
        let pipelineServices: [SimpleService]
        if let cacheHit = searchForBestCacheHit(cache: cache) {
            startingDataset = cacheHit.1
            previouslyChosenServices = cacheHit.0
            pipelineServices = Array(services[cacheHit.0.count...])
        }
        else {
            startingDataset = dataset
            previouslyChosenServices = []
            pipelineServices = services
        }

        return pipelineServices.reduce(startingDataset, { (res: PythonObject, current: SimpleService) -> PythonObject in
            let result = current.run(
                on: res,
                withContext: SimpleContext(previouslyChosenServices: previouslyChosenServices)
            )
            previouslyChosenServices.append(current)

            return result
        })
    }

    private func searchForBestCacheHit(
        cache: [([SimpleService], PythonObject)]?
    ) -> ([SimpleService], PythonObject)? {
        var bestHit: ([SimpleService], PythonObject)? = nil

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