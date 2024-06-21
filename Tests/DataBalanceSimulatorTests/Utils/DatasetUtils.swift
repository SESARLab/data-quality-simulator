import PythonKit
import Logging

import XCTest

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
        XCTAssertEqual(Int(df.size)!, size)
    }
}