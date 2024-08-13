import PythonKit

struct StatsCalculator {
    let originalDataset: PythonObject

    let filteredDataset: PythonObject

    let pipeline: Pipeline

    let metricName: String

    let filteredPercent: Double

    let metricValue: Double

    init(
        originalDataset: PythonObject, 
        filteredDataset: PythonObject,
        pipeline: Pipeline,
        metricName: String
    ) throws {
        guard !pipeline.services.isEmpty else {
            throw GenericErrors.InvalidState("Pipeline cannot run with 0 services")
        } 

        self.originalDataset = originalDataset
        self.filteredDataset = filteredDataset
        self.metricName = metricName
        self.pipeline = pipeline

        let getLeftPercentage = PythonModulesStore.getAttr(
            obj: PythonModulesStore.metrics, 
            attr: "non_none_percentage"
        )
        self.filteredPercent = Double(getLeftPercentage(df1: originalDataset, df2: filteredDataset))!

        let metricCalculator = PythonModulesStore.getAttr(
            obj: PythonModulesStore.metrics, 
            attr: metricName
        )
        self.metricValue = Double(metricCalculator(df1: originalDataset, df2: filteredDataset))!
    }
}