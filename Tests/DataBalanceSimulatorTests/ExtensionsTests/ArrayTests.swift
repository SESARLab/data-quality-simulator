import XCTest
@testable import DataBalanceSimulator

public class ArrayTests: XCTestCase {
    func testGivenArrayOfSize0_whenComputeAverage_thenReturn0() throws {
        let arr: [Double] = []
        
        let average = arr.average

        XCTAssertEqual(average, 0)
    }

    func testGivenArrayOfSize1_whenComputeAverage_thenReturnFirstElement() throws {
        let arr: [Double] = [2.0]
        
        let average = arr.average

        XCTAssertEqual(average, arr[0])
    }

    func testGivenArrayOfSizeN_whenComputeAverage_thenReturnAverage() throws {
        let arr = [1.0, 1.5, 3.5]
        
        let average = arr.average

        XCTAssertEqual(average, 2.0)
    }

    func testGivenMatrix_whenGetCartesianProduct_thenComputeCombinations() throws {
        let matrix = [[1, 2], [3, 4], [5, 6]]

        let result = matrix.cartesianProduct()

        XCTAssertEqual(result.count, 8)
        XCTAssert(result.firstIndex(of: [1, 3, 5]) != nil)
        XCTAssert(result.firstIndex(of: [1, 3, 6]) != nil)
        XCTAssert(result.firstIndex(of: [1, 4, 5]) != nil)
        XCTAssert(result.firstIndex(of: [1, 4, 6]) != nil)
        XCTAssert(result.firstIndex(of: [2, 3, 5]) != nil)
        XCTAssert(result.firstIndex(of: [2, 3, 6]) != nil)
        XCTAssert(result.firstIndex(of: [2, 4, 5]) != nil)
        XCTAssert(result.firstIndex(of: [2, 4, 6]) != nil)
    }

    func testGivenEmptyMatrix_whenGetCartesianProduct_thenReturnEmpty() throws {
        let matrix: [[Int]] = []

        let result = matrix.cartesianProduct()

        XCTAssertEqual(result.count, 0)
    }

    func testGiven1ElementMatrix_whenGetCartesianProduct_thenReturnItself() throws {
        let matrix = [[1, 2]]

        let result = matrix.cartesianProduct()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], [1, 2])
    }
}