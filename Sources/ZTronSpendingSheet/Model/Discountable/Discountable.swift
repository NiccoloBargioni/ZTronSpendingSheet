import Foundation

internal protocol Discountable: Sendable, Identifiable, Cloneable {
    func getPriceOffPercentage() -> Double
}

extension Discountable {
    internal func getPriceOffPercentage() -> Double {
        return 1.0
    }
}
