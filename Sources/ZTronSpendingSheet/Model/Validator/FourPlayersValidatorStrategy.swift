public final class FourPlayersValidatorStrategy: SpendingValidatorStrategy {
    public func validate(purchases: [Player : [any Purchaseable]]) -> Bool {
        return false
    }
}
