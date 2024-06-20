import XCTest
@testable import DataBalanceSimulator

public class DoubleTests: XCTestCase {
    func testGiven0_whenCastToBytes_thenReturnAll0() throws {
        let d = 0.0
        
        let result = d.bytes

        XCTAssertEqual([UInt8](repeating: 0, count: 8), result)
    }

    func testGiven1_whenCastToBytes_thenReturnBinaryRepresentation() throws {
        let d = 1.0
        
        let result = d.bytes

        XCTAssertEqual([UInt8](repeating: 0, count: 6) + [240, 63], result)
    }

    func testGivenMinDoubleInRange_whenNormalize_thenReturnScaledMin() {
        let d = 1.0
        
        let result = d.normalize(min: 1, max: 2, from: 3, to: 9)

        XCTAssertEqual(result, 3)
    }

    func testGivenMaxDoubleInRange_whenNormalize_thenReturnScaledMax() {
        let d = 1.0
        
        let result = d.normalize(min: 0, max: 1, from: 3, to: 9)

        XCTAssertEqual(result, 9)
    }

    func testGivenDoubleInRange_whenNormalize_thenReturnScaled() {
        let d = 2.0
        
        let result = d.normalize(min: 0, max: 3, from: 3, to: 9)

        XCTAssertEqual(result, 7)
    }
}