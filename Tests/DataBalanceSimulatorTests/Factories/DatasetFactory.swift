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

    // public static func build(withVariability variability: Double = 0.5) -> PythonObject {
    //     assert(variability >= 0 && variability <= 1)
    //     pd.Dataframe(np.array())
    //     return SimpleService(
    //         id: 1, 
    //         filteringSeed: 0,
    //         experimentSeed: 10,
    //         filterLowerBound: 0.5, 
    //         filterUpperBound: 0.8
    //     )
    // }
}