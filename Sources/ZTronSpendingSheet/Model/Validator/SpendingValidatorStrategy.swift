import Foundation

public protocol SpendingValidatorStrategy: Sendable {
    func validate(purchases: [Player: [any Purchaseable]]) -> Bool
}
