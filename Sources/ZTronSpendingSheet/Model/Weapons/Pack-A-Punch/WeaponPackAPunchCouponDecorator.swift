import Foundation

public final class WeaponPackAPunchCouponDecorator: WeaponPackAPunchDecorator {
    let discountDecorator: any Discountable
    
    public let id: String
    public let decorated: WeaponPackAPunch

    init(decorated: WeaponPackAPunch, coupon: any Discountable) {
        self.id = decorated.id + " w/ coupon"
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
}
