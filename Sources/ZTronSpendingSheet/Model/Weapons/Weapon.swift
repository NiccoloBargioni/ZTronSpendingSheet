import Foundation

public final class Weapon: PurchaseableWeaponDecorator, @unchecked Sendable {
    public let player: Player?
    
    private let name: String
    private let price: Double
    private let description: String
    private let assetsImageName: String
    private var categories: Set<PurchaseableCategory>
    private var availability: Int
    
    private let categoriesSemaphore = DispatchSemaphore(value: 1)
    private let availabilitySemaphore = DispatchSemaphore(value: 1)
    
    public let id: String
    
    public init(name: String, price: Double, description: String, assetsImageName: String, categories: Set<PurchaseableCategory>, availability: Int, player: Player?) {
        self.name = name
        self.price = price
        self.id = name
        self.assetsImageName = assetsImageName
        self.description = description
        self.player = player
        self.availability = availability
        
        self.categories = .init()
        categories.forEach { category in
            self.categories.insert(category)
        }
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getDescription() -> String {
        return self.description
    }
    
    public func getAssetsImage() -> String {
        return self.assetsImageName
    }
    
    public func getCategories() -> Set<PurchaseableCategory> {
        self.categoriesSemaphore.wait()
        
        defer {
            self.categoriesSemaphore.signal()
        }
        
        var copy = Set<PurchaseableCategory>.init()
        self.categories.forEach { category in
            copy.insert(category)
        }
        
        return copy
    }
    
    public func getPrice() -> Double {
        return self.price
    }
    
    public func makeDeepCopy() -> Self {
        // Constructor makes a defensive copy of categories anyway
        self.categoriesSemaphore.wait()
        self.availabilitySemaphore.wait()
        
        defer {
            self.availabilitySemaphore.signal()
            self.categoriesSemaphore.signal()
        }
        
        return Self(name: self.name, price: self.price, description: self.description, assetsImageName: self.assetsImageName, categories: self.categories, availability: self.availability, player: self.player)
    }
    
    public func getAvailability() -> Int {
        return self.availability
    }
    
    public func decrementAvailability() {
        self.availability = max(self.availability - 1, 0)
    }
}
