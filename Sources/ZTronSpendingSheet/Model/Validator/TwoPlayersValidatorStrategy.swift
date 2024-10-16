import Foundation

internal final class TwoPlayersValidatorStrategy: SpendingValidatorStrategy {
    func validate(purchases: [any Purchaseable]) -> Bool {
        return false
    }
}
