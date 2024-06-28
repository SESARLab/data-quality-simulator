import XCTest

import SQLite
@testable import DataBalanceSimulator

public class ExecResultsStorageTests: XCTestCase {
    let dbPath = "file::memory:?cache=shared"
    var db: Connection? = nil

    override public func setUp() {
        do {
            self.db = try Connection(dbPath)
        }
        catch {
            XCTFail("Cannot connect to db: \(error)")
        }

        var seedScript: String = ""
        do {
            seedScript = try FileUtils.getContent(ofFile: "./db/init/seed.sql")
        }
        catch {
            XCTFail("Cannot read file seed.sql: \(error)")
        }

        do {
            try db?.execute(seedScript)
        }
        catch {
            XCTFail("Cannot execute seed script: \(error)")
        }
    }

    override public func tearDown() {
        do {
            try self.db?.run(ExecResultsStorage.table.drop())
        }
        catch {
            XCTFail("Cannot drop table: \(error)")
        }
    }

    func testGivenExecutionResults_whenStore_thenInsertIntoDb() throws {
        let execResults = SimulatorCLI.ExecutionResults(
            executionTime: 1.0, 
            experimentId: 2, 
            windowSize: 3,
            maxNodes: 4,
            nodesCount: 5, 
            maxServices: 6, 
            servicesCount: 7, 
            dataset: "dataset1", 
            metricName: "metric1", 
            metricValue: 8.0, 
            percentage: 0.5, 
            lowerBound: 0.1, 
            upperBound: 0.8
        )
        let storage = try ExecResultsStorage(dbPath: dbPath)

        try storage.insert(execResults)

        XCTAssertEqual(try self.db!.scalar(ExecResultsStorage.table.count), 1)
        let row = Array(try db!.prepare(ExecResultsStorage.table))[0]
        XCTAssertEqual(row[ExecResultsStorage.executionTime], 1.0)
        XCTAssertEqual(row[ExecResultsStorage.experimentId], 2)
        XCTAssertEqual(row[ExecResultsStorage.windowSize], 3)
        XCTAssertEqual(row[ExecResultsStorage.maxNodes], 4)
        XCTAssertEqual(row[ExecResultsStorage.nodesCount], 5)
        XCTAssertEqual(row[ExecResultsStorage.maxServices], 6)
        XCTAssertEqual(row[ExecResultsStorage.servicesCount], 7)
        XCTAssertEqual(row[ExecResultsStorage.dataset], "dataset1")
        XCTAssertEqual(row[ExecResultsStorage.metricName], "metric1")
        XCTAssertEqual(row[ExecResultsStorage.metricValue], 8.0)
        XCTAssertEqual(row[ExecResultsStorage.percentage], 0.5)
        XCTAssertEqual(row[ExecResultsStorage.lowerBound], 0.1)
        XCTAssertEqual(row[ExecResultsStorage.upperBound], 0.8)
    }
}