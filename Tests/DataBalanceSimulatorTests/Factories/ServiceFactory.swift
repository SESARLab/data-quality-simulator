@testable import DataBalanceSimulator

class RowFilterServiceFactory {
    public static func build(withId id: Int = 1, withFilterPercent filterPercent: Double? = nil) -> RowFilterService {
        let lowerBound = filterPercent ?? 0.5
        let upperBound = filterPercent ?? 0.8
        return RowFilterService(
            id: id, 
            experimentSeed: 10,
            filterLowerBound: lowerBound, 
            filterUpperBound: upperBound
        )
    }

    public static func buildGroups(withFilterPercents filterPercents: [Double]...) -> [[RowFilterService]] {
        return Array(0..<filterPercents.count).map { groupIndex in
            Array(0..<filterPercents[groupIndex].count).map { elemIndex in
                RowFilterServiceFactory.build(
                    withId: groupIndex * elemIndex, 
                    withFilterPercent: filterPercents[groupIndex][elemIndex]
                )
            }
        }
    }
}

class ColumnFilterServiceFactory {
    public static func build(withId id: Int = 1, withFilterPercent filterPercent: Double? = nil) -> ColumnFilterService {
        let lowerBound = filterPercent ?? 0.5
        let upperBound = filterPercent ?? 0.8
        return ColumnFilterService(
            id: id, 
            experimentSeed: 10,
            filterLowerBound: lowerBound, 
            filterUpperBound: upperBound,
            columnFrac: 0.5
        )
    }
}

class RowAndColumnFilterServiceFactory {
    public static func build(withId id: Int = 1, withFilterPercent filterPercent: Double? = nil) -> RowAndColumnFilterService {
        let lowerBound = filterPercent ?? 0.5
        let upperBound = filterPercent ?? 0.8
        return RowAndColumnFilterService(
            id: id, 
            experimentSeed: 10,
            filterLowerBound: lowerBound, 
            filterUpperBound: upperBound,
            columnFrac: 0.5
        )
    }
}