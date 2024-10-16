import Foundation

internal final class WeaponPackAPunchDecorator: PurchaseableWeaponDecorator {
    private let decorated: any PurchaseableWeaponDecorator
    private static let PACK_A_PUNCH_PRICE: Double = 1000.0
    internal let id: String
    
    internal init(decoratedWeapon: any PurchaseableWeaponDecorator) {
        self.decorated = decoratedWeapon.makeDeepCopy()
        self.id = decorated.getName() + " w/ pack-a-punch"
    }
    
    internal func getName() -> String {
        return decorated.getName() + " w/ pack-a-punch"
    }
    
    internal func getPrice() -> Double {
        Self.PACK_A_PUNCH_PRICE + decorated.getPrice()
    }
    
    internal func makeDeepCopy() -> Self {
        return Self(decoratedWeapon: decorated.makeDeepCopy())
    }
    
    internal func getDecoratedWeapon() -> any PurchaseableWeaponDecorator {
        return self.decorated.makeDeepCopy()
    }
}
