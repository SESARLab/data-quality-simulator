import XCTest
@testable import DataBalanceSimulator

public class RowFilterServiceTests: XCTestCase {
    func testGivenRowFilterServiceAsFirst_whenRun_thenFilterDataset() throws {
        let s = RowFilterServiceFactory.build(withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [],
            accumulatedFilteringSeed: [],
            originalDataset: dataset
        ))

        DatasetUtils.assertSizeWithoutNone(of: dataset, isEqualTo: 100)
        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: filteredDataset, isEqualTo: 50)
    }

    func testGivenRowFilterServiceAsSecond_whenRun_thenFilterDataset() throws {
        let s = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let prevService = RowFilterServiceFactory.build(withId: 2)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [prevService],
            accumulatedFilteringSeed: prevService.filteringSeed,
            originalDataset: dataset
        ))

        DatasetUtils.assertSizeWithoutNone(of: dataset, isEqualTo: 100)
        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: filteredDataset, isEqualTo: 50)
        
    }
}

public class ColumnFilterServiceTests: XCTestCase {
    func testGivenColumnFilterServiceAsFirst_whenRun_thenFilterDataset() throws {
        let s = ColumnFilterServiceFactory.build(
            withRowSamplingPercent: 0.5, withColumnSamplingPercent: 1
        )
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [],
            accumulatedFilteringSeed: [],
            originalDataset: dataset
        ))

        DatasetUtils.assertSizeWithoutNone(of: dataset, isEqualTo: 100)
        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: filteredDataset, satisfy: { $0 <= 50 })
    }

    func testGivenRowFilterServiceAsSecond_whenRun_thenFilterDataset() throws {
        let s = ColumnFilterServiceFactory.build(
            withRowSamplingPercent: 0.5, withColumnSamplingPercent: 1
        )
        let prevService = ColumnFilterServiceFactory.build(withId: 2)
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [prevService],
            accumulatedFilteringSeed: prevService.filteringSeed,
            originalDataset: dataset
        ))

        DatasetUtils.assertSizeWithoutNone(of: dataset, isEqualTo: 100)
        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: filteredDataset, satisfy: { $0 <= 50 })
    }
}

public class RowAndColumnFilterServiceTests: XCTestCase {
    func testGivenRowAndColumnFilterServiceAsFirst_whenRun_thenFilterDataset() throws {
        let s = RowAndColumnFilterServiceFactory.build(
            withRowSamplingPercent: 0.5, withColumnSamplingPercent: 1
        )
        let dataset = DatasetFactory.build(withDatasetSize: 100)

        let filteredDataset = s.run(on: dataset, withContext: Context(
            previouslyChosenServices: [],
            accumulatedFilteringSeed: [],
            originalDataset: dataset
        ))

        DatasetUtils.assertSizeWithoutNone(of: dataset, isEqualTo: 100)
        DatasetUtils.assertSize(of: filteredDataset, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: filteredDataset, satisfy: { $0 <= 50 })
    }
}