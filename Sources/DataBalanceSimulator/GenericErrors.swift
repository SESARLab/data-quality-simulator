enum GenericErrors: Error, Equatable {
    case InvalidState(String)
    case Timeout(String)
}