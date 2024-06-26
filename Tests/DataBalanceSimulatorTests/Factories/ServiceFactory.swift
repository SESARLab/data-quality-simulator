@testable import DataBalanceSimulator

class SimpleServiceFactory {
    public static func build(withId id: Int = 1, withFilterPercent filterPercent: Double? = nil) -> SimpleService {
        let lowerBound = filterPercent ?? 0.5
        let upperBound = filterPercent ?? 0.8
        return SimpleService(
            id: id, 
            filteringSeed: 0,
            experimentSeed: 10,
            filterLowerBound: lowerBound, 
            filterUpperBound: upperBound
        )
    }

    public static func buildGroups(withFilterPercents filterPercents: [Double]...) -> [[SimpleService]] {
        return Array(0..<filterPercents.count).map { groupIndex in
            Array(0..<filterPercents[groupIndex].count).map { elemIndex in
                SimpleServiceFactory.build(
                    withId: groupIndex * elemIndex, 
                    withFilterPercent: filterPercents[groupIndex][elemIndex]
                )
            }
        }
    }
}