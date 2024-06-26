extension String {
    func getFileName() -> String {
        return self.split(separator: ".").dropLast().joined(separator: ".")
    }
}