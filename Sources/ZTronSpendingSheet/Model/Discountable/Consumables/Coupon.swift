import Foundation

public protocol Coupon: Discountable {
    var type: CouponType { get }
    var rarity: Rarity { get }
    var remainingActivations: Int { get set }

    @discardableResult func changeRarity(to newRarity: Rarity) -> Bool
}

extension Coupon {
    var activationsCount: Int {
        return Rarity.rarityPriority[self.rarity]! + 1 - self.remainingActivations
    }
}
