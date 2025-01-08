import Foundation

public final class WeaponPackAPunch: PurchaseableWeaponDecorator, DiscountDecorator, @unchecked Sendable {
    public var coupon: (any Coupon)? = nil
    
    public let discountDecorator: any Discountable
    
    private let decorated: any PurchaseableWeaponDecorator
    private static let PACK_A_PUNCH_PRICE: Double = 1000.0
    
    public let id: String
    
    public init(decoratedWeapon: any PurchaseableWeaponDecorator, coupon: any Discountable = NoPriceOffCoupon()) {
        self.decorated = decoratedWeapon.makeDeepCopy()
        self.discountDecorator = coupon.makeDeepCopy()
        self.id = decoratedWeapon.getName() + " w/ pack-a-punch"
    }
    
    public func getName() -> String {
        return decorated.getName() + " w/ pack-a-punch"
    }
    
    public func getDescription() -> String {
        return self.decorated.getDescription()
    }
    
    public func getCategories() -> Set<PurchaseableCategory> {
        return decorated.getCategories()
    }
    
    public func getAssetsImage() -> String {
        return decorated.getAssetsImage()
    }
    
    public func getPrice() -> Double {
        Self.PACK_A_PUNCH_PRICE * (1 - self.discountDecorator.getPriceOffPercentage()) + decorated.getPrice()
    }
    
    public func makeDeepCopy() -> Self {
        return Self(decoratedWeapon: decorated.makeDeepCopy(), coupon: self.discountDecorator.makeDeepCopy())
    }
    
    public func getDecoratedWeapon() -> any PurchaseableWeaponDecorator {
        return self.decorated.makeDeepCopy()
    }
    
    public func getAvailability() -> Int {
        return self.decorated.getAvailability()
    }
    
    public func decrementAvailability(amount: Int = 1) {
        self.decorated.decrementAvailability(amount: amount)
    }
    
    public func increaseAvailability(amount: Int = 1) {
        self.decorated.increaseAvailability(amount: amount)
    }
    
    public func getAmount() -> Int {
        return self.decorated.getAmount()
    }
    
    public func increaseAmount() {
        self.decorated.increaseAmount()
    }
    
    public func decreaseAmount() {
        self.decorated.decreaseAmount()
    }
    
    public func getCompatibleCoupons() -> [CouponType] {
        return self.decorated.getCompatibleCoupons()
    }
    
    @discardableResult public func removeCoupon(_ coupon: CouponType) -> Bool {
        return self.decorated.removeCoupon(coupon)
    }
}
