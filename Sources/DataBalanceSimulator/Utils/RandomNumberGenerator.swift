import Foundation

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    
    // https://forums.swift.org/t/random-number-generation-with-seed/62367/2
    func next() -> UInt64 {
        return UInt64(drand48() * 0x1.0p64) ^ UInt64(drand48() * 0x1.0p16) 
    }
}