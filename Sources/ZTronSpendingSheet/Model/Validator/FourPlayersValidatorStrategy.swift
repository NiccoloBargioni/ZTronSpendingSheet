public final class FourPlayersValidatorStrategy: SpendingValidatorStrategy {
    public init() {  }

    public func validate(purchases: [Player : [any Purchaseable]]) -> Bool {
        return false
    }
}
