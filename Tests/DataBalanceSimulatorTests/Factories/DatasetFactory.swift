import PythonKit

@testable import DataBalanceSimulator

class DatasetFactory {
    static let pd = Python.import("pandas")

    static let np = Python.import("numpy")

    /// return a Dataframe of size `size`
    /// - Parameter size: the size of the Dataframe
    /// - Returns: Dataframe
    public static func build(withDatasetSize size: Int = 100) -> PythonObject {
        let data = np.array([Int](0..<size))

        let df = pd.DataFrame(data, columns: ["field"])

        return df
    }
}