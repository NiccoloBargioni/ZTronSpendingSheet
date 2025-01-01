import Foundation

public final class Weapon: PurchaseableWeaponDecorator {
    public let player: Player
    
    private let name: String
    private let price: Double
    private let description: String
    public let id: String
    
    public init(name: String, price: Double, description: String, player: Player) {
        self.name = name
        self.price = price
        self.id = name
        self.description = description
        self.player = player
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getDescription() -> String {
        return self.description
    }
    
    public func getPrice() -> Double {
        return self.price
    }
    
    public func makeDeepCopy() -> Self {
        return Self(name: self.name, price: self.price, description: self.description, player: self.player)
    }
}
