import Foundation

class TimeMonitor {
    private var doneSamplings: Int    

    let totalSamplings: Int

    private let minServices: Int
    private let maxServices: Int
    private let minNodes: Int
    private let maxNodes: Int
    private let maxWindowSize: Int

    init(minServices: Int, maxServices: Int, minNodes: Int, maxNodes: Int, maxWindowSize: Int) {
        var total: Int = 0
        for s in minServices...maxServices {
            for n in minNodes...maxNodes {
                for w in 1...min(maxWindowSize, n) {
                    let winSamplings = Int(pow(Double(s),Double(w)))
                    total += (n - w + 1) * winSamplings + n
                }
            }
        }
        
        self.minServices = minServices
        self.maxServices = maxServices
        self.minNodes = minNodes
        self.maxNodes = maxNodes
        self.maxWindowSize = maxWindowSize

        self.doneSamplings = 0
        self.totalSamplings = total
    }

    func completeWindow(services: Int, nodes: Int, winSize: Int, isLastWindow: Bool) {
        self.doneSamplings += Int(pow(Double(services),Double(winSize))) + 
            (isLastWindow ? nodes : 0)
    }

    func getDoneSampling() -> Int {
        return self.doneSamplings
    }
    
    func getCompletionPercent() -> Int {
        return Int(round(Double(self.doneSamplings) / Double(self.totalSamplings) * 100))
    }
}