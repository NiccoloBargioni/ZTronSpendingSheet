import Foundation

internal final class ThreePlayersValidatorStrategy: SpendingValidatorStrategy {
    func validate(purchases: [any Purchaseable]) -> Bool {
        return false
    }
}
