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

    private func assertRowContainsExecResults(row: Row, execResults: SimulatorCLI.ExecutionResults) {
        XCTAssertEqual(row[ExecResultsStorage.executionTime], execResults.executionTime)
        XCTAssertEqual(row[ExecResultsStorage.experimentId], execResults.experimentId)
        XCTAssertEqual(row[ExecResultsStorage.windowSize], execResults.windowSize)
        XCTAssertEqual(row[ExecResultsStorage.maxNodes], execResults.maxNodes)
        XCTAssertEqual(row[ExecResultsStorage.nodesCount], execResults.nodesCount)
        XCTAssertEqual(row[ExecResultsStorage.maxServices], execResults.maxServices)
        XCTAssertEqual(row[ExecResultsStorage.servicesCount], execResults.servicesCount)
        XCTAssertEqual(row[ExecResultsStorage.dataset], execResults.dataset)
        XCTAssertEqual(row[ExecResultsStorage.metricName], execResults.metricName)
        XCTAssertEqual(row[ExecResultsStorage.metricValue], execResults.metricValue)
        XCTAssertEqual(row[ExecResultsStorage.percentage], execResults.percentage)
        XCTAssertEqual(row[ExecResultsStorage.rowLowerBound], execResults.rowLowerBound)
        XCTAssertEqual(row[ExecResultsStorage.rowUpperBound], execResults.rowUpperBound)
        XCTAssertEqual(row[ExecResultsStorage.columnLowerBound], execResults.columnLowerBound)
        XCTAssertEqual(row[ExecResultsStorage.columnUpperBound], execResults.columnUpperBound)
        XCTAssertEqual(row[ExecResultsStorage.description], execResults.description)
    }

    func testGivenExecutionResults_whenStore_thenInsertIntoDb() throws {
        let execResults = ExecResultsFactory.build()
        let storage = try ExecResultsStorage(dbPath: dbPath)

        try storage.insert(execResults)

        XCTAssertEqual(try self.db!.scalar(ExecResultsStorage.table.count), 1)
        let row = Array(try db!.prepare(ExecResultsStorage.table))[0]
        assertRowContainsExecResults(row: row, execResults: execResults)
    }

    func testGivenLockedDb_whenStoreExecResults_thenRetryUntilInsert() throws {
        let execResults = ExecResultsFactory.build()
        let storage = try ExecResultsStorage(dbPath: dbPath)
        // lock the database: from https://stackoverflow.com/q/14272715/5587393
        try self.db?.execute("PRAGMA locking_mode = EXCLUSIVE; BEGIN EXCLUSIVE;")
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 5)
            print("Unlocking db... 🔓")
            try! self.db?.execute("COMMIT; PRAGMA locking_mode = NORMAL;SELECT * FROM results LIMIT 1;")
            print("Db unlocked ✅")
        }

        try storage.insert(execResults)

        XCTAssertEqual(try self.db!.scalar(ExecResultsStorage.table.count), 1)
        let row = Array(try db!.prepare(ExecResultsStorage.table))[0]
        assertRowContainsExecResults(row: row, execResults: execResults)
    }
}