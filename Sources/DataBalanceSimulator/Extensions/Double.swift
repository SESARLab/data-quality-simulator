extension BinaryFloatingPoint {
    /// Returns the decimal value as a byte array
    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }

    /// Returns normalized value for the range between a and b
    /// - Parameters:
    ///   - min: minimum of the range of the measurement
    ///   - max: maximum of the range of the measurement
    ///   - a: minimum of the 
    ///   - b: maximum of the scaled range
    func normalize(min: Self, max: Self, from a: Self, to b: Self) -> Self {
        (b - a) * ((self - min) / (max - min)) + a
    }
}