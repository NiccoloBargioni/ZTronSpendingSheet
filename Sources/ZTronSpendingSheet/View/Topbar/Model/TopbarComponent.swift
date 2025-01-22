internal protocol TopbarComponent: AnyObject, Sendable, Equatable {
    func getIcon() -> String
    func getName() -> String
}
