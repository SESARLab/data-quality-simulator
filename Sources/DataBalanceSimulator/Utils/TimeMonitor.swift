import Foundation

class TimeMonitor {
    private var doneSamplings: Int

    let totalSamplings: Int

    private let minServices: Int
    private let maxServices: Int
    private let minNodes: Int
    private let maxNodes: Int
    private let maxWindowSize: Int

    private let calendar = Calendar.current
    private let startTime: Date
    private var estimatedFinishTime: Date 

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

        self.startTime = Date.now
        self.estimatedFinishTime = startTime
    }

    /// updates the current estimations and statistics about the simulation execution
    /// - Parameters:
    ///   - services: number of services
    ///   - nodes: number of nodes
    ///   - winSize: the window size
    ///   - isLastWindow: True if the window is the last one, False otherwise
    func completeWindow(services: Int, nodes: Int, winSize: Int, isLastWindow: Bool) {
        self.doneSamplings += Int(pow(Double(services),Double(winSize))) + 
            (isLastWindow ? nodes : 0)

        let executionTime = calendar.dateComponents(
            [.second], 
            from: self.startTime,
            to: Date.now
        )

        let executionSeconds = executionTime.second!
        let estimatedFinishSeconds = executionSeconds * self.totalSamplings / self.doneSamplings

        self.estimatedFinishTime = self.startTime.addingTimeInterval(TimeInterval(estimatedFinishSeconds))
    }

    func getDoneSampling() -> Int {
        return self.doneSamplings
    }

    /// expresses the time left in the format dd:hh:mm:ss
    /// - Returns: a string in the described format
    func getEstimatedTimeLeft() -> String {
        let estimatedTimeLeft = calendar.dateComponents(
            [.day, .hour, .minute, .second], 
            from: Date.now,
            to: self.estimatedFinishTime
        )

        return self.convertTimeIntervalToString(interval: estimatedTimeLeft)
    }

    private func convertTimeIntervalToString(interval: DateComponents) -> String {
        let day = String(interval.day!)
        let hour = String(format: "%02d", interval.hour!)
        let minute = String(format: "%02d", interval.minute!)
        let second = String(format: "%02d", interval.second!)

        return "\(day):\(hour):\(minute):\(second)"
    }
    
    /// return the completion time percent
    /// - Returns: the percent of done samplings over the total ones
    func getCompletionPercent() -> Int {
        return Int(round(Double(self.doneSamplings) / Double(self.totalSamplings) * 100))
    }

    /// returns the execution time starting from the moment TimeMonitor was initialized
    /// - Returns: the execution time in the format `dd:hh:mm:ss`
    func getExecutionTime() -> String {
        let executionTime = calendar.dateComponents(
            [.day, .hour, .minute, .second], 
            from: self.startTime,
            to: Date.now
        )

        return self.convertTimeIntervalToString(interval: executionTime)
    }
}