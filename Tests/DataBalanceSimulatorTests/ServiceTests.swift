import XCTest
@testable import DataBalanceSimulator

public class SimpleServiceTests: XCTestCase {
    func testGivenSimpleService_whenRun_thenFilterDataset() throws {
        var s = SimpleServiceFactory.build()
        let prevService = SimpleServiceFactory.build(withId: 2)
        let dataset = DatasetFactory.build()
        s.previouslyChosenServices = [prevService]

        let filteredDataset = s.run(dataset)

        DatasetUtils.assertSizeIsSmaller(for: filteredDataset, comparedTo: dataset)
    }
}