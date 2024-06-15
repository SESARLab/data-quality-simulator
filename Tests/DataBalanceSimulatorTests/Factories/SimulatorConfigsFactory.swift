class SimulatorConfigsFactory {
    public static func build() -> SimulatorConfigs {
        return SimulatorConfigs(
            seed: 1, 
            minNodes: 2,
            maxNodes: 3,
            minServices: 2, 
            maxServices: 3, 
            lowerBound: 0.1, 
            upperBound: 1
        )
    }
}