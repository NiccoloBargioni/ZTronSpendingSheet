import Foundation
import Ifrit

internal protocol Purchaseable: Identifiable, Sendable, Cloneable, Discountable, ObservableObject, IfriSearchable {
    var id: String { get }
    var coupon: (any Coupon)? { get }
    
    func getCategories() -> Set<PurchaseableCategory>
    func getAssetsImage() -> String
    func getName() -> String
    func getDescription() -> String
    func getPrice() -> Double
    func getAvailability() -> Int
    func decrementAvailability(amount: Int) -> Void
    func increaseAvailability(amount: Int) -> Void
    func getAmount() -> Int
    func increaseAmount() -> Void
    func decreaseAmount() -> Void
    
    func getCompatibleCoupons() -> [CouponType]
    @discardableResult func applyCouponIfCompatible(_ coupon: any Coupon) -> Bool
    @discardableResult func removeCoupon(_ coupon: CouponType) -> Bool
}



internal extension Purchaseable {
    func decrementAvailability(amount: Int = 1) {  }
    func increaseAvailability(amount: Int = 1) {  }
    @discardableResult func applyCouponIfCompatible(_ coupon: any Coupon) -> Bool { return false }
    
    var propertiesCustomWeight: [FuseProp] {
        return [
            FuseProp(getName().fromLocalized(), weight: 1.0),
        ]
    }
}
