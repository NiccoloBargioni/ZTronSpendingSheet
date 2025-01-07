import Foundation

public protocol Coupon: Discountable {
    var type: CouponType { get }
    
    func changeRarity(to newRarity: Rarity)
}
