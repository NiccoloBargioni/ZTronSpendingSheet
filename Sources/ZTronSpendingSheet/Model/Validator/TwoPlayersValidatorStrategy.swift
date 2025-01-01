import Foundation

public final class TwoPlayersValidatorStrategy: SpendingValidatorStrategy {
    public func validate(purchases: [Player : [any Purchaseable]]) -> Bool {
        return false
    }
}
