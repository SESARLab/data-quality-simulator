import CryptoSwift
import PythonKit
import Foundation

protocol Service: Equatable {
    var id: Int { get }
    func run(_ dataframe: PythonObject) -> PythonObject
}

extension Service {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SimpleService: Service, CustomStringConvertible {
    var id: Int

    let experimentSeed: Int

    let filteringSeed: Double

    let filterLowerBound: Double

    let filterUpperBound: Double

    var description: String {
        return "S" + String(format: "%02d", id)
    }

    var previouslyChosenServices: [Self] = []
    var finalFilteringPercent: Double {
        precondition(!previouslyChosenServices.isEmpty)
        
        let servicesLineageSeed = self.previouslyChosenServices.flatMap { $0.filteringSeed.bytes } +
            self.filteringSeed.bytes

        return generatePercent(usingHashFrom: servicesLineageSeed)
    }

    init(id: Int, 
        filteringSeed: Double? = nil, 
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double
    ) {
        self.id = id
        self.filteringSeed = filteringSeed ?? Double.random(in: 0...1)
        self.experimentSeed = experimentSeed
        self.filterLowerBound = filterLowerBound
        self.filterUpperBound = filterUpperBound
    }

    /// Run the service and filter using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    /// - Returns: the filtered dataframe
    func run(_ dataframe: PythonObject) -> PythonObject {
        return dataframe.sample(
            frac: self.finalFilteringPercent,
            random_state: self.experimentSeed
        )
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
