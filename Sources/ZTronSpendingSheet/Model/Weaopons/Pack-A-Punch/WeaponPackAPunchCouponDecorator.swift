import Foundation

public final class WeaponPackAPunchCouponDecorator: WeaponPackAPunchDecorator {
    let discountDecorator: any Discountable
    
    public let id: String
    public let player: Player
    public let decorated: WeaponPackAPunch
    
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

}
