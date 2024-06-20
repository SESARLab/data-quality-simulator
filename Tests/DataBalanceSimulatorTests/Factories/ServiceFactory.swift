@testable import DataBalanceSimulator

class SimpleServiceFactory {
    public static func build(withId id: Int = 1) -> SimpleService {
        return SimpleService(
            id: id, 
            filteringSeed: 0,
            experimentSeed: 10,
            filterLowerBound: 0.5, 
            filterUpperBound: 0.8
        )
    }
}