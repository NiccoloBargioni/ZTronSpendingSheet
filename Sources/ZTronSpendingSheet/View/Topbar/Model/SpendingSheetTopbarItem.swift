import Foundation

internal final class SpendingSheetTopbarItem: TopbarComponent, @unchecked Sendable, ObservableObject {
    private let icon: String
    private let name: String
    internal let couponType: CouponType
    
    @Published private var rarity: Rarity = .common
    
    
    private let rarityLock = DispatchSemaphore(value: 1)
    
    internal init(icon: String, name: String, type: CouponType) {
        self.icon = icon
        self.name = name
        self.couponType = type
    }
    
    internal func getIcon() -> String {
        return self.icon
    }
    
    internal func getName() -> String {
        return self.name
    }
    
    internal func getRarity() -> Rarity {
        self.rarityLock.wait()
        
        defer {
            self.rarityLock.signal()
        }
        
        return self.rarity
    }
    
    internal func setRarity(_ rarity: Rarity) {
        self.rarityLock.wait()
        self.rarity = rarity
        self.rarityLock.signal()
    }
    
    internal static func == (lhs: SpendingSheetTopbarItem, rhs: SpendingSheetTopbarItem) -> Bool {
        return lhs.icon == rhs.icon && lhs.name == rhs.name && lhs.couponType == rhs.couponType && lhs.rarity == rhs.rarity
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(self.icon)
        hasher.combine(self.name)
    }
}
