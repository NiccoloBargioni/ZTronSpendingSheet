import Foundation

internal final class Weapon: PurchaseableWeaponDecorator {
    private let name: String
    private let price: Double
    internal let id: String
    
    internal init(name: String, price: Double) {
        self.name = name
        self.price = price
        self.id = name
    }
    
    internal func getName() -> String {
        return self.name
    }
    
    internal func getPrice() -> Double {
        return self.price
    }
    
    internal func makeDeepCopy() -> Self {
        return Self(name: self.name, price: self.price)
    }
}
