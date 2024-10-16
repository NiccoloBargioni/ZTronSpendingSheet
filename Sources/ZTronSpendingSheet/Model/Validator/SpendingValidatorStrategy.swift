import Foundation

internal protocol SpendingValidatorStrategy: Sendable {
    func validate(purchases: [any Purchaseable]) -> Bool
}
