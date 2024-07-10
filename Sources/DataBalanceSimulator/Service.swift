import CryptoSwift
import PythonKit
import Foundation
import Logging

class BaseService: Equatable, CustomStringConvertible {
    var id: Int

    let serviceSeed: Int

    let filteringSeed: [UInt8]

    let filterLowerBound: Double

    let filterUpperBound: Double

    let logger: Logger

    init(id: Int,
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double
    ) {
        self.id = id
        // TODO: Instead of class name length you could use the sum of the ascii codes % 2^8
        self.serviceSeed = id + ((experimentSeed + 1) << 16) + (String(describing: type(of: self)).count << 8)
        var randomGenerator = RandomNumberGeneratorWithSeed(seed: serviceSeed)
        self.filteringSeed = Double.random(in: 0...1, using: &randomGenerator).bytes
        self.filterLowerBound = filterLowerBound
        self.filterUpperBound = filterUpperBound
        self.logger = Logger.createWithLevelFromEnv(fileName: #file)
    }

    func run(on dataframe: PythonObject, 
        withContext context: Context, 
        inPlace: Bool = false
    ) -> PythonObject {
        assertionFailure("This method should be never called on the base class")
        return dataframe
    }

    public func finalFilteringPercent(from context: Context) -> Double {
        let servicesLineageSeed = context.accumulatedFilteringSeed + self.filteringSeed

        return generatePercent(usingHashFrom: servicesLineageSeed)
    }

    private func generatePercent(usingHashFrom x: [UInt8]) -> Double {
        let percent = Double(x.crc32()) / Double(UInt32.max)
        let normalizedPercent = percent.normalize(
            min: 0, 
            max: 1, 
            from: self.filterLowerBound, 
            to: self.filterUpperBound
        )
        return normalizedPercent
    }

    static func == (lhs: BaseService, rhs: BaseService) -> Bool {
        return lhs.id == rhs.id
    }

    var description: String {
        get {
            return "S" + String(format: "%02d", id)
        }
    }
}

struct Context {
    var previouslyChosenServices: [BaseService]
    var accumulatedFilteringSeed: [UInt8]
}

class RowFilterService: BaseService {
    override init(id: Int,
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double
    ) {
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            filterLowerBound: filterLowerBound, 
            filterUpperBound: filterUpperBound
        )

        logger.log(withDescription: "Creating RF Service \(id)", withProps: [
            "filteringSeed" : "\(filteringSeed)"
        ])
    }

    override var description: String {
        get {
            return "RF" + super.description
        }
    }

    /// Run the service and filter rows using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe
    override public func run(on dataframe: PythonObject, 
        withContext context: Context, 
        inPlace: Bool = false
    ) -> PythonObject {
        return PythonModulesStore.sampling.sample_rows(
            df: dataframe,
            frac: self.finalFilteringPercent(from: context),
            random_state: self.serviceSeed,
            in_place: inPlace
        )
    }
}

class ColumnFilterService: BaseService {
    let columnFrac: Double

    init(id: Int,
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double,
        columnFrac: Double
    ) {
        self.columnFrac = columnFrac
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            filterLowerBound: filterLowerBound, 
            filterUpperBound: filterUpperBound
        )

        logger.log(withDescription: "Creating CF Service \(id)", withProps: [
            "filteringSeed" : "\(filteringSeed)"
        ])
    }

    /// Run the service and filter columns (as many as column_frac) using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe
    override public func run(on dataframe: PythonObject, 
        withContext context: Context, 
        inPlace: Bool = false
    ) -> PythonObject {
        return PythonModulesStore.sampling.sample_columns(
            df: dataframe,
            columns_frac: self.columnFrac,
            rows_frac: self.finalFilteringPercent(from: context),
            random_state: self.serviceSeed,
            in_place: inPlace
        )
    }

    override var description: String {
        get {
            return "CF" + super.description
        }
    }
}

class RowAndColumnFilterService: BaseService {
    let rowFilterService: RowFilterService
    let columnFilterService: ColumnFilterService

    init(id: Int,
        experimentSeed: Int,
        filterLowerBound: Double,
        filterUpperBound: Double,
        columnFrac: Double
    ) {
        self.rowFilterService = RowFilterService(id: id,
            experimentSeed: experimentSeed, 
            filterLowerBound: filterLowerBound, 
            filterUpperBound: filterUpperBound
        )
        self.columnFilterService = ColumnFilterService(id: id,
            experimentSeed: experimentSeed,
            filterLowerBound: filterLowerBound, 
            filterUpperBound: filterUpperBound,
            columnFrac: columnFrac
        )
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            filterLowerBound: filterLowerBound, 
            filterUpperBound: filterUpperBound
        )

        logger.log(withDescription: "Creating RCF Service \(id)", withProps: [
            "filteringSeed" : "\(filteringSeed)"
        ])
    }

    /// combine the row and column filtering
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe
    override public func run(on dataframe: PythonObject, 
        withContext context: Context, 
        inPlace: Bool = false
    ) -> PythonObject {
        let modifiedDf =  self.rowFilterService.run(
            on: dataframe, 
            withContext: context, 
            inPlace: inPlace
        )
        return self.columnFilterService.run(
            on: modifiedDf,
            withContext: context,
            inPlace: true
        )
    }

    override var description: String {
        get {
            return "RCF" + super.description
        }
    }
}