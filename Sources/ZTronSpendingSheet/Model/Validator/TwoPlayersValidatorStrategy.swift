import Foundation

public final class TwoPlayersValidatorStrategy: SpendingValidatorStrategy {
    public init() {  }
    
    public func validate(purchases: [Player : [any Purchaseable]]) -> Bool {
        return false
    }
}
