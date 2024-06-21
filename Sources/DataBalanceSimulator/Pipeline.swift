import PythonKit

class Pipeline {
    let services: [SimpleService]

    init(services: [SimpleService]) throws {
        guard !services.isEmpty else {
            throw GenericErrors.InvalidState("Pipeline cannot run with 0 services")
        }
        self.services = services
    }

    public func run(on data: PythonObject) -> PythonObject {
        var previouslyChosenServices: [SimpleService] = []
        return services.reduce(data, { (res: PythonObject, current: SimpleService) -> PythonObject in
            let result = current.run(
                on: res,
                withContext: SimpleContext(previouslyChosenServices: previouslyChosenServices)
            )
            previouslyChosenServices.append(current)

            return result
        })
    }
}