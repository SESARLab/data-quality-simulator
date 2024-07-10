import XCTest
@testable import DataBalanceSimulator

public class PipelineTests: XCTestCase {
    func testGivenPipelineWith0Services_whenCreated_thenThrow() throws {
        XCTAssertThrowsError(
            try PipelineFactory.build(withServices: []),
            "Pipeline cannot run with 0 services", 
            { error in
                XCTAssertEqual(
                    error as? GenericErrors, 
                    GenericErrors.InvalidState("Pipeline cannot run with 0 services")
                )
            }
        )
    }

    func testGivenPipelineWith1Service_whenRun_thenExecute1() throws {
        let s = RowFilterServiceFactory.build(withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let pipeline = try PipelineFactory.build(withServices: [s])

        let result = pipeline.run(on: dataset)

        DatasetUtils.assertSize(of: result.output, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: result.output, isEqualTo: 50)
    }

    func testGivenPipelineWithMultipleServices_whenRun_thenExecuteSequentially() throws {
        let s1 = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = RowFilterServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let pipeline = try PipelineFactory.build(withServices: [s1, s2])

        let result = pipeline.run(on: dataset)

        DatasetUtils.assertSize(of: result.output, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: result.output, satisfy: { $0 < 50 && $0 >= 25 })
    }

    func testGivenPipelineWithCacheEmpty_whenRun_thenExecuteAllServices() throws {
        let s1 = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = RowFilterServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let pipeline = try PipelineFactory.build(withServices: [s1, s2])

        let result = pipeline.run(on: dataset, withCache: [])

        DatasetUtils.assertSize(of: result.output, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: result.output, satisfy: { $0 < 50 && $0 >= 25 })
    }

    func testGivenPipelineWithCacheMiss_whenRun_thenExecuteAllServices() throws {
        let s1 = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = RowFilterServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let s3 = RowFilterServiceFactory.build(withId: 3, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let dumbDataset = DatasetFactory.build(withDatasetSize: 1)
        let pipeline = try PipelineFactory.build(withServices: [s1, s2])

        let result = pipeline.run(on: dataset, withCache: [([s3], dumbDataset)])

        DatasetUtils.assertSize(of: result.output, isEqualTo: 100)
        DatasetUtils.assertSizeWithoutNone(of: result.output, satisfy: { $0 < 50 && $0 >= 25 })
    }

    func testGivenPipelineWithCacheHit_whenRun_thenExecuteRemainingServices() throws {
        let s1 = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = RowFilterServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let cachedDataset = DatasetFactory.build(withDatasetSize: 10)
        let pipeline = try PipelineFactory.build(withServices: [s1, s2])

        let result = pipeline.run(on: dataset, withCache: [([s1], cachedDataset)])

        DatasetUtils.assertSize(of: result.output, isEqualTo: 10)
        DatasetUtils.assertSizeWithoutNone(of: result.output, satisfy: { $0 < 10 && $0 >= 5 })
    }

    func testGivenPipelineWithAllCached_whenRun_thenReturnCachedDataset() throws {
        let s1 = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = RowFilterServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let cachedDataset = DatasetFactory.build(withDatasetSize: 10)
        let pipeline = try PipelineFactory.build(withServices: [s1, s2])

        let result = pipeline.run(on: dataset, withCache: [([s1, s2], cachedDataset)])

        DatasetUtils.assertSize(of: result.output, isEqualTo: 10)
        DatasetUtils.assertSizeWithoutNone(of: result.output, isEqualTo: 10)
    }

    func testGivenPipelineWithQuantitativeMetric_whenRun_thenReturnStats() throws {
        let s1 = RowFilterServiceFactory.build(withId: 1, withFilterPercent: 0.5)
        let s2 = RowFilterServiceFactory.build(withId: 2, withFilterPercent: 0.5)
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let pipeline = try PipelineFactory.build(withServices: [s1, s2])

        let result = pipeline.run(on: dataset)

        XCTAssert(result.statsCalculator.filteredPercent < 0.50 && result.statsCalculator.filteredPercent >= 0.25)
        XCTAssert(result.statsCalculator.metricValue > 2.0 && result.statsCalculator.metricValue <= 4.0)
    }
}