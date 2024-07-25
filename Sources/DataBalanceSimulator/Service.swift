import CryptoSwift
import PythonKit
import Foundation
import Logging

class BaseService: Equatable, CustomStringConvertible {
    let id: Int

    let serviceSeed: Int

    var randomGenerator: RandomNumberGeneratorWithSeed

    let filteringSeed: [UInt8]

    let rowLowerBound: Double

    let rowUpperBound: Double

    let logger: Logger

    init(id: Int,
        experimentSeed: Int,
        rowLowerBound: Double,
        rowUpperBound: Double
    ) {
        self.id = id
        // TODO: Instead of class name length you could use the sum of the ascii codes % 2^8
        self.serviceSeed = id + ((experimentSeed + 1) << 16) + (String(describing: type(of: self)).count << 8)
        self.randomGenerator = RandomNumberGeneratorWithSeed(seed: serviceSeed)
        self.filteringSeed = Double.random(in: 0...1, using: &randomGenerator).bytes
        self.rowLowerBound = rowLowerBound
        self.rowUpperBound = rowUpperBound
        self.logger = Logger.createWithLevelFromEnv(fileName: #file)
    }

    func run(on dataframe: PythonObject, 
        withContext context: Context, 
        inPlace: Bool = false
    ) -> PythonObject {
        assertionFailure("This method should be never called on the base class")
        return dataframe
    }

    fileprivate func finalFilteringPercent(from context: Context) -> Double {
        let servicesLineageSeed = context.accumulatedFilteringSeed + self.filteringSeed

        return generatePercent(usingHashFrom: servicesLineageSeed)
    }

    private func generatePercent(usingHashFrom x: [UInt8]) -> Double {
        let percent = Double(x.crc32()) / Double(UInt32.max)
        let normalizedPercent = percent.normalize(
            min: 0, 
            max: 1, 
            from: self.rowLowerBound, 
            to: self.rowUpperBound
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
    var originalDataset: PythonObject
}

class RowFilterService: BaseService {
    override init(id: Int,
        experimentSeed: Int,
        rowLowerBound: Double,
        rowUpperBound: Double
    ) {
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound
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
    var columnFrac: Double?

    var categoricalDatasetsMap: [String: PythonObject] = [:]

    init(id: Int,
        experimentSeed: Int,
        rowLowerBound: Double,
        rowUpperBound: Double,
        columnLowerBound: Double,
        columnUpperBound: Double
    ) {
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound
        )
        self.columnFrac = Double.random(in: 0...1, using: &self.randomGenerator)
            .normalize(min: 0, max: 1, from: columnLowerBound, to: columnUpperBound)

        logger.log(withDescription: "Creating CF Service \(id)", withProps: [
            "filteringSeed" : "\(self.filteringSeed)",
            "column_frac" : "\(self.columnFrac)"
        ])
    }

    /// Run the service and filter columns (until column_frac remains) using the percent computed by finalFilteringPercent
    /// - Parameters:
    ///   - dataframe: Pandas dataframe containing the dataset
    ///   - context: the execution context, which includes the previously executed services
    /// - Returns: the filtered dataframe
    override public func run(on dataframe: PythonObject, 
        withContext context: Context, 
        inPlace: Bool = false
    ) -> PythonObject {
        let categoricalDataset: PythonObject
        let originalDataframeId = PythonModulesStore.getPythonId(obj: context.originalDataset)
        if self.categoricalDatasetsMap.keys.contains(originalDataframeId) {
            categoricalDataset = self.categoricalDatasetsMap[originalDataframeId]!
        }
        else {
            logger.debug("Building categorical DataFrame with id = \(originalDataframeId)...")

            let samplingModule = PythonModulesStore.sampling
            let createCategoricalDfFn = PythonModulesStore.getAttr(obj: samplingModule, attr: "create_categorical_df")
            categoricalDataset = createCategoricalDfFn(df: context.originalDataset, random_state: self.serviceSeed)
            self.categoricalDatasetsMap[originalDataframeId] = categoricalDataset

            logger.debug("Categorical DataFrame with id = \(originalDataframeId) built ✅")
        }

        return PythonModulesStore.sampling.sample_columns(
            df: dataframe,
            df_with_categories: categoricalDataset,
            columns_frac: self.columnFrac,
            cat_frac: self.finalFilteringPercent(from: context),
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
        rowLowerBound: Double,
        rowUpperBound: Double,
        columnLowerBound: Double,
        columnUpperBound: Double
    ) {
        self.rowFilterService = RowFilterService(id: id,
            experimentSeed: experimentSeed, 
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound
        )
        self.columnFilterService = ColumnFilterService(id: id,
            experimentSeed: experimentSeed,
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound,
            columnLowerBound: columnLowerBound,
            columnUpperBound: columnUpperBound
        )
        super.init(id: id, 
            experimentSeed: experimentSeed, 
            rowLowerBound: rowLowerBound, 
            rowUpperBound: rowUpperBound
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