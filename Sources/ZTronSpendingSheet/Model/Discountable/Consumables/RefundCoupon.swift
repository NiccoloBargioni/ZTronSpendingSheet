import Foundation

internal final class RefundCoupon: Coupon, @unchecked Sendable {
    internal let type: CouponType = .refundCoupon
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
        return 0.25
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
}
