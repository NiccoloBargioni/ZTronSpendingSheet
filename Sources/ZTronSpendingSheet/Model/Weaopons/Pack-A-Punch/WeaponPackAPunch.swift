import Foundation

public final class WeaponPackAPunch: PurchaseableWeaponDecorator, DiscountDecorator {
    public let discountDecorator: any Discountable
    
    private let decorated: any PurchaseableWeaponDecorator
    private static let PACK_A_PUNCH_PRICE: Double = 1000.0
    
    public let player: Player
    public let id: String
    
    public init(decoratedWeapon: any PurchaseableWeaponDecorator, coupon: any Discountable = NoPriceOffCoupon()) {
        self.decorated = decoratedWeapon.makeDeepCopy()
        self.discountDecorator = coupon.makeDeepCopy()
        self.id = decoratedWeapon.getName() + " w/ pack-a-punch"
        self.player = decoratedWeapon.player
    }
    
    public func getName() -> String {
        return decorated.getName() + " w/ pack-a-punch"
    }
    
    public func getDescription() -> String {
        return self.decorated.getDescription()
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
}
