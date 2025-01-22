public final class FourPlayersValidatorStrategy: SpendingValidatorStrategy {
    public init() {  }

    public func validate(purchases: [Player : [any Purchaseable]], for quest: SpendingQuest) -> Bool {
        guard let player1Purchases = purchases[.player1] else { return false }
        guard let player2Purchases = purchases[.player2] else { return false }
        guard let player3Purchases = purchases[.player3] else { return false }
        guard let player4Purchases = purchases[.player4] else { return false }
        
        let allPurchases: [any Purchaseable] = .init().appending(contentsOf: player1Purchases).appending(contentsOf: player2Purchases)
        let allMandatoryIncluded = FourPlayersValidatorStrategy.mandatory.reduce(true) { isValid, nextMandatoryPurchase in
            return isValid && allPurchases.contains { purchase in
                return purchase.id == nextMandatoryPurchase.id
            }
        }
        
        if allMandatoryIncluded {
            switch quest {
            case .pommel:
                return FourPlayersValidatorStrategy.getTotalCost(of: allPurchases) <= 10_000.0
            case .easterEgg:
                return FourPlayersValidatorStrategy.getTotalCost(of: player1Purchases) <= 9_000.0 &&
                    FourPlayersValidatorStrategy.getTotalCost(of: player2Purchases) <= 9_000.0 &&
                        FourPlayersValidatorStrategy.getTotalCost(of: player3Purchases) <= 9_000.0 &&
                            FourPlayersValidatorStrategy.getTotalCost(of: player4Purchases) <= 9_000.0
            }
        } else {
            return false
        }
    }
}
