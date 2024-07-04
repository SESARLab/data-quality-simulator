import XCTest
@testable import DataBalanceSimulator

public class SimpleServiceTests: XCTestCase {
    func testGivenSimpleServiceAsFirst_whenRun_thenFilterDataset() throws {
        let s = RowFilterServiceFactory.build(withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [],
            accumulatedFilteringSeed: []
        ))

        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 50)
    }

    func testGivenSimpleServiceAsSecond_whenRun_thenFilterDataset() throws {
        let s = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let prevService = RowFilterServiceFactory.build(withId: 2)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [prevService],
            accumulatedFilteringSeed: prevService.filteringSeed
        ))

        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 50)
    }
}