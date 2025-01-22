import Foundation

internal protocol SpendingValidatorStrategy: Sendable {
    func validate(purchases: [Player: [any Purchaseable]], for quest: SpendingQuest) -> Bool
}

internal extension SpendingValidatorStrategy {
    static func makeStrategyFor(players: Int) -> any SpendingValidatorStrategy {
        assert(players >= 2 && players <= 4)
        
        switch players {
        case 2:
            return TwoPlayersValidatorStrategy()
        case 3:
            return ThreePlayersValidatorStrategy()
        case 4:
            return FourPlayersValidatorStrategy()
        default:
            fatalError("Expected 2, 3, or 4 players, but got \(players)")
        }
    }
    
    static var mandatory: [any Purchaseable] {
        return spendingPurchaseables.filter { purchase in
            return purchase.getCategories().contains(.mandatory)
        }
    }
    
    static func getTotalCost(of purchases: [any Purchaseable]) -> Double {
        return purchases.reduce(0.0) { result, purchase in
            return result + purchase.getPrice()
        }
    }
}
