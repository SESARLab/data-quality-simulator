import XCTest
@testable import DataBalanceSimulator

public class SimpleServiceTests: XCTestCase {
    func testGivenSimpleServiceAsFirst_whenRun_thenFilterDataset() throws {
        let s = SimpleServiceFactory.build()
        let dataset = DatasetFactory.build()

        let filteredDataset = s.run(on: dataset, withContext: SimpleContext(previouslyChosenServices: []))

        DatasetUtils.assertSizeIsSmaller(for: filteredDataset, comparedTo: dataset)
    }

    func testGivenSimpleServiceAsSecond_whenRun_thenFilterDataset() throws {
        let s = SimpleServiceFactory.build()
        let prevService = SimpleServiceFactory.build(withId: 2)
        let dataset = DatasetFactory.build()

        let filteredDataset = s.run(on: dataset, withContext: SimpleContext(previouslyChosenServices: [prevService]))

        DatasetUtils.assertSizeIsSmaller(for: filteredDataset, comparedTo: dataset)
    }
}