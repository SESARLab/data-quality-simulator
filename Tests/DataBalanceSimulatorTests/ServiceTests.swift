import XCTest
@testable import DataBalanceSimulator

public class SimpleServiceTests: XCTestCase {
    func testGivenSimpleServiceAsFirst_whenRun_thenFilterDataset() throws {
        let s = SimpleServiceFactory.build(withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: SimpleContext(
            previouslyChosenServices: [],
            accumulatedFilteringSeed: []
        ))

        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 50)
    }

    func testGivenSimpleServiceAsSecond_whenRun_thenFilterDataset() throws {
        let s = SimpleServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let prevService = SimpleServiceFactory.build(withId: 2)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: SimpleContext(
            previouslyChosenServices: [prevService],
            accumulatedFilteringSeed: prevService.filteringSeed
        ))

        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 50)
    }
}