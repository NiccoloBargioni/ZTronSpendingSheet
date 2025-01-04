import Foundation

public final class ThreePlayersValidatorStrategy: SpendingValidatorStrategy {
    public init() {  }
    
    public func validate(purchases: [Player : [any Purchaseable]]) -> Bool {
        return false
    }
}
