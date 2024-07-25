@testable import DataBalanceSimulator

class RowFilterServiceFactory {
    public static func build(withId id: Int = 1, withFilterPercent filterPercent: Double? = nil) -> RowFilterService {
        let rowLowerBound = filterPercent ?? 0.5
        let rowUpperBound = filterPercent ?? 0.8
        return RowFilterService(
            id: id, 
            experimentSeed: 10,
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound
        )
    }

    public static func buildGroups(withFilterPercents filterPercents: [Double]...) -> [[RowFilterService]] {
        return Array(0..<filterPercents.count).map { groupIndex in
            Array(0..<filterPercents[groupIndex].count).map { elemIndex in
                let serviceId = (groupIndex * filterPercents[groupIndex].count) + elemIndex
                return RowFilterServiceFactory.build(
                    withId: serviceId, 
                    withFilterPercent: filterPercents[groupIndex][elemIndex]
                )
            }
        }
    }
}

class ColumnFilterServiceFactory {
    public static func build(withId id: Int = 1, 
        withRowSamplingPercent rowSamplingPercent: Double? = nil,
        withColumnSamplingPercent columnSamplingPercent: Double? = nil
    ) -> ColumnFilterService {
        let rowLowerBound = rowSamplingPercent ?? 0.5
        let rowUpperBound = rowSamplingPercent ?? 0.8
        let columnLowerBound = columnSamplingPercent ?? 0.5
        let columnUpperBound = columnSamplingPercent ?? 0.8
        return ColumnFilterService(
            id: id, 
            experimentSeed: 10,
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound,
            columnLowerBound: columnLowerBound, 
            columnUpperBound: columnUpperBound
        )
    }
}

class RowAndColumnFilterServiceFactory {
    public static func build(withId id: Int = 1, 
        withRowSamplingPercent rowSamplingPercent: Double? = nil,
        withColumnSamplingPercent columnSamplingPercent: Double? = nil
    ) -> RowAndColumnFilterService {
        let rowLowerBound = rowSamplingPercent ?? 0.5
        let rowUpperBound = rowSamplingPercent ?? 0.8
        let columnLowerBound = columnSamplingPercent ?? 0.5
        let columnUpperBound = columnSamplingPercent ?? 0.8
        return RowAndColumnFilterService(
            id: id, 
            experimentSeed: 10,
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound,
            columnLowerBound: columnLowerBound, 
            columnUpperBound: columnUpperBound
        )
    }
}