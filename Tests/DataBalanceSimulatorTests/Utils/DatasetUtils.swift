import PythonKit
import Logging

import XCTest

public class DatasetUtils {
    public static func assertSizeIsSmaller(
        for df1: PythonObject, 
        comparedTo df2: PythonObject
    ) {
        XCTAssert(Int(df1.size)! < Int(df2.size)!)
    }
}