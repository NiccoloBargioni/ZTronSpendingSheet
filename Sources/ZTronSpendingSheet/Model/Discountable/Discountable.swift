import Foundation

public protocol Discountable: Sendable, Identifiable, Cloneable {
    func getPriceOffPercentage() -> Double
}

extension Discountable {
    public func getPriceOffPercentage() -> Double {
        return 1.0
    }
}
