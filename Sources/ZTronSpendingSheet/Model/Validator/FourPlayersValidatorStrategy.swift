import Foundation

internal final class FourPlayersValidatorStrategy: SpendingValidatorStrategy {
    func validate(purchases: [any Purchaseable]) -> Bool {
        return false
    }
}
