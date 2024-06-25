import PythonKit

enum MetricNames: String, CaseIterable, LosslessStringConvertible {
    case qualitative
    case quantitative

    init?(_ description: String) {
        self.init(rawValue: description)
    }

    var description: String {
        return self.rawValue
    }
}

struct StatsCalculator {
    let originalDataset: PythonObject

    let filteredDataset: PythonObject

    let pipeline: Pipeline

    let metricName: MetricNames

    let filteredPercent: Double

    let metricValue: Double

    init(
        originalDataset: PythonObject, 
        filteredDataset: PythonObject,
        pipeline: Pipeline,
        metricName: MetricNames
    ) throws {
        guard !pipeline.services.isEmpty else {
            throw GenericErrors.InvalidState("Pipeline cannot run with 0 services")
        } 

        self.originalDataset = originalDataset
        self.filteredDataset = filteredDataset
        self.metricName = metricName
        self.pipeline = pipeline

        // TODO: filteredDataset.count / originalDataset.count ?
        var accumulatedFilteringSeed: [UInt8] = []
        var previousServices: [SimpleService] = []
        self.filteredPercent = self.pipeline.services.reduce(1.0, { (result, current) -> Double in 
            let newPercent = result * current.finalFilteringPercent(from: SimpleContext(
                previouslyChosenServices: previousServices,
                accumulatedFilteringSeed: accumulatedFilteringSeed))
            previousServices.append(current)
            accumulatedFilteringSeed += current.filteringSeed

            return newPercent
        })

        let metricCalculator = PythonModulesStore.getAttr(
            module: PythonModulesStore.metrics, 
            attr: metricName.rawValue
        )
        self.metricValue = Double(metricCalculator(df1: originalDataset, df2: filteredDataset))!
    }
}