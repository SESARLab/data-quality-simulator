import PythonKit
import Logging

import XCTest
@testable import DataBalanceSimulator

public class DatasetUtils {
    public static func assertSizeIsSmaller(
        for df1: PythonObject, 
        comparedTo df2: PythonObject
    ) {
        XCTAssertLessThan(Int(df1.size)!, Int(df2.size)!)
    }

    public static func assertSize(
        of df: PythonObject,
        isEqualTo size: Int
    ) {
        XCTAssertEqual(Int(df.shape[0])!, size)
    }

    public static func assertSizeWithoutNone(
        of df: PythonObject,
        isEqualTo size: Int
    ) {
        let df_no_none = df.dropna()
        XCTAssertEqual(Int(df_no_none.shape[0])!, size)
    }

    public static func assertSizeWithoutNone(
        of df: PythonObject,
        satisfy condition: (Int) -> Bool
    ) {
        let df_no_none = df.dropna()
        XCTAssert(condition(Int(df_no_none.shape[0])!))
    }

    public static func assertCount(
        ofSeries series: PythonObject,
        isEqualTo count: Int
    ) {
        let countFn = PythonModulesStore.getAttr(obj: series, attr: "count")
        XCTAssertEqual(Int(countFn())!, count)
    }
}