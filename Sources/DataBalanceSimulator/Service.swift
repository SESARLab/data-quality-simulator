import CryptoSwift
import PythonKit
import Foundation

protocol Service: Equatable {
    var id: Int { get }
    func run(on dataframe: PythonObject, withContext context: Context) -> PythonObject
}

protocol Context {}

struct SimpleContext: Context {
    var previouslyChosenServices: [SimpleService]
    var accumulatedFilteringSeed: [UInt8]
}

extension Service {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SimpleService: Service, CustomStringConvertible {
    var id: Int

    let experimentSeed: Int

    let filteringSeed: [UInt8]

    let filterLowerBound: Double

    let filterUpperBound: Double

    var description: String {
        return "S" + String(format: "%02d", id)
    }

    init(id: Int, 
        filteringSeed: Double? = nil, 
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double
    ) {
        self.id = id
        self.filteringSeed = (filteringSeed ?? Double.random(in: 0...1)).bytes
        self.experimentSeed = experimentSeed
        self.filterLowerBound = filterLowerBound
        self.filterUpperBound = filterUpperBound
    }

    /// Run the service and filter using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe and the filtering percent applied
    public func run(on dataframe: PythonObject, withContext context: Context) -> PythonObject {
        precondition(context is SimpleContext, "A SimpleService requires a SimpleContext when it runs")

        let ctx = context as! SimpleContext

        return dataframe.sample(
            frac: self.finalFilteringPercent(from: ctx),
            random_state: self.experimentSeed
        )
    }

    public func finalFilteringPercent(from context: SimpleContext) -> Double {
        let servicesLineageSeed = context.accumulatedFilteringSeed + self.filteringSeed

        return generatePercent(usingHashFrom: servicesLineageSeed)
    }

    private func generatePercent(usingHashFrom x: [UInt8]) -> Double {
        let percent = Double(x.crc32()) / pow(2, 32)
        let normalizedPercent = percent.normalize(
            min: 0, 
            max: 1, 
            from: self.filterLowerBound, 
            to: self.filterUpperBound
        )
        return normalizedPercent
    }
}