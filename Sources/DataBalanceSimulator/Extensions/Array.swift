import Algorithms

extension Array where Element: BinaryFloatingPoint {
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}

extension Array where Element: RandomAccessCollection, Element.Index == Int {
    func cartesianProduct() -> [[Element.Element]] {
        if self.isEmpty || self.count == 1 {
            // type mismatch if returns self
            return self.map { $0.map { $0 } }
        }

        // Algorithms does not provide a `product` with ariety > 2, so
        // we need to compose the `product` calls
        return self.dropFirst().reduce(self[0].map { [$0] }) { result, array in
            Algorithms.product(result, array).map { (resultElement, arrayElement) in
                resultElement + [arrayElement]
            }
        }
    }
}