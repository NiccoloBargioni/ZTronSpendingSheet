import Foundation

public protocol Coupon: Discountable {
    var type: CouponType { get }
    var rarity: Rarity { get }
    var remainingActivations: Int { get set }
    
    @discardableResult func changeRarity(to newRarity: Rarity) -> Bool
    func use() -> Void
    func release() -> Void
}

extension Coupon {
    var activationsCount: Int {
        return Rarity.rarityPriority[self.rarity]! + 1 - self.remainingActivations
    }
}

extension Coupon {
    static func == (_ lhs: any Coupon, _ rhs: any Coupon) -> Bool {
        return lhs.type == rhs.type && lhs.rarity == rhs.rarity && lhs.remainingActivations == rhs.remainingActivations
    }
}
