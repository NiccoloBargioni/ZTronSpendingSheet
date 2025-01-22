import Foundation

internal extension Array {
    func appending(contentsOf: Self) -> Self {
        var copy = Array.init(self)
        copy.append(contentsOf: contentsOf)
        return copy
    }
}
