import Foundation

public final class WeaponPackAPunchCouponDecorator: WeaponPackAPunchDecorator {
    
    let discountDecorator: any Discountable
    
    public let id: String
    public let decorated: WeaponPackAPunch
    public let player: Player?

    init(decorated: WeaponPackAPunch, coupon: any Discountable) {
        self.id = decorated.id + " w/ coupon"
        self.player = decorated.player
        self.decorated = decorated.makeDeepCopy()
        self.discountDecorator = coupon.makeDeepCopy()
    }
    
    public func getName() -> String {
        return self.decorated.getName() + " w/ coupon"
    }
    
    public func getDescription() -> String {
        return self.decorated.getDescription()
    }
    
    public func getPrice() -> Double {
        return self.decorated.getPrice() * 0.75
    }
    
    public func makeDeepCopy() -> Self {
        return Self(decorated: self.decorated.makeDeepCopy(), coupon: self.discountDecorator.makeDeepCopy())
    }
    
    public func getCategories() -> Set<PurchaseableCategory> {
        return decorated.getCategories()
    }
    
    public func getAssetsImage() -> String {
        return decorated.getAssetsImage()
    }

}
