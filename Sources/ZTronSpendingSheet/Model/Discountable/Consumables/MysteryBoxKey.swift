import Foundation

internal final class MysteryBoxKey: Coupon, @unchecked Sendable {
    internal let type: CouponType = .mysteryBoxKey
    private(set) internal var rarity: Rarity

    public var remainingActivations: Int
    
    private let remainingActivationsLock = DispatchSemaphore(value: 1)
    private let rarityLock = DispatchSemaphore(value: 1)
    
    
    internal init(rarity: Rarity) {
        self.rarityLock.wait()
        self.rarity = rarity
        self.rarityLock.signal()
        
        switch rarity {
            case .common:
                self.remainingActivations = 1
            case .rare:
                self.remainingActivations = 2
            case .legendary:
                self.remainingActivations = 3
            case .epic:
                self.remainingActivations = 4
            }
    }
    
    internal func makeDeepCopy() -> Self {
        return .init(rarity: self.rarity)
    }
    
    internal func getPriceOffPercentage() -> Double {
        return 0.5
    }
    
    @discardableResult func changeRarity(to newRarity: Rarity) -> Bool {
        self.remainingActivationsLock.wait()
        
        defer {
            self.remainingActivationsLock.signal()
        }
        
        let activations = self.activationsCount
        self.remainingActivations = Rarity.rarityPriority[newRarity]! + 1 - self.activationsCount

        if remainingActivations < 0 {
            self.remainingActivations = activations
            return false
        } else {
            self.rarityLock.wait()
            self.rarity = newRarity
            self.rarityLock.signal()
            return true
        }
    }
    
    internal func use() {
        self.remainingActivationsLock.wait()
        if self.remainingActivations > 0 {
            self.remainingActivations -= 1
        }
        self.remainingActivationsLock.signal()
    }
    
    internal func release() {
        self.remainingActivationsLock.wait()
        self.remainingActivations = max(self.remainingActivations + 1, Rarity.rarityPriority[self.rarity]! + 1)
        self.remainingActivationsLock.signal()
    }
}
