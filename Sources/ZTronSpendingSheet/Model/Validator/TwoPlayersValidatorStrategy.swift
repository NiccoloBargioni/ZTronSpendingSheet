import Foundation

internal final class TwoPlayersValidatorStrategy: SpendingValidatorStrategy {
    internal init() {  }
    
    internal func validate(purchases: [Player : [any Purchaseable]], for quest: SpendingQuest) -> Bool {
        guard let player1Purchases = purchases[.player1] else { return false }
        guard let player2Purchases = purchases[.player2] else { return false }
        
        let allPurchases: [any Purchaseable] = .init().appending(contentsOf: player1Purchases).appending(contentsOf: player2Purchases)
        let allMandatoryIncluded = TwoPlayersValidatorStrategy.mandatory.reduce(true) { isValid, nextMandatoryPurchase in
            return isValid && nextMandatoryPurchase.getAvailability() <= 0 && allPurchases.contains { purchase in
                return purchase.id == nextMandatoryPurchase.id
            }
        }
        
        if allMandatoryIncluded {
            switch quest {
            case .pommel:
                return TwoPlayersValidatorStrategy.getTotalCost(of: allPurchases) <= 10_000.0
            case .easterEgg:
                return TwoPlayersValidatorStrategy.getTotalCost(of: player1Purchases) <= 9_000.0 && TwoPlayersValidatorStrategy.getTotalCost(of: player2Purchases) <= 9_000.0
            }
        } else {
            return false
        }
    }
}
