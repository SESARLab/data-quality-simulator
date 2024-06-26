import XCTest
@testable import DataBalanceSimulator

public class SimulationTests: XCTestCase {
    func testGivenSimulationWithGreaterWinSizeThanNodes_whenCreated_thenThrow() throws {
        XCTAssertThrowsError(
            try SimulationFactory.build(withNodes: [], withWindowSize: 2),
            "windowSize must be smaller than the number of nodes", 
            { error in
                XCTAssertEqual(
                    error as? GenericErrors, 
                    GenericErrors.InvalidState("windowSize must be smaller than the number of nodes")
                )
            }
        )
    }

    func testGivenSimulationWith2NodesAndWin1_whenRun_thenChooseBestCombination() throws {
        let nodes = SimpleServiceFactory.buildGroups(
            withFilterPercents: [0.1, 0.5], [0.5, 0.1]
        )
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let sim = try SimulationFactory.build(
            withNodes: nodes, 
            withWindowSize: 1
        )

        let result = try sim.run(on: dataset)

        XCTAssertEqual(result.metric, 0.25)
        XCTAssertEqual(result.percentage, 0.25)
    }

    func testGivenSimulationWith3NodesAndWin2_whenRun_thenChooseBestCombination() throws {
        let nodes = SimpleServiceFactory.buildGroups(
            withFilterPercents: [0.1, 0.5], [0.5, 0.1], [0.1, 0.5]
        )
        let dataset = DatasetFactory.build(withDatasetSize: 64)
        let sim = try SimulationFactory.build(
            withNodes: nodes,
            withWindowSize: 1
        )

        let result = try sim.run(on: dataset)

        XCTAssertEqual(result.metric, 0.125)
        XCTAssertEqual(result.percentage, 0.125)
    }

    func testGivenSimulationWithSameWinAndNodeCount_whenRun_thenChooseBestCombination() throws {
        let nodes = SimpleServiceFactory.buildGroups(
            withFilterPercents: [0.1, 0.5], [0.5, 0.1]
        )
        let dataset = DatasetFactory.build(withDatasetSize: 100)
        let sim = try SimulationFactory.build(
            withNodes: nodes,
            withWindowSize: 2
        )

        let result = try sim.run(on: dataset)

        XCTAssertEqual(result.metric, 0.25)
        XCTAssertEqual(result.percentage, 0.25)
    }
}