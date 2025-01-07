import Foundation

internal final class RefundCoupon: Coupon, @unchecked Sendable {
    internal let type: CouponType = .refundCoupon
    
    public var remainingActivations: Int
    
    private let remainingActivationsLock = DispatchSemaphore(value: 1)
    private let rarity: Rarity

    internal init(rarity: Rarity) {
        self.rarity = rarity
        
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
    
    func changeRarity(to newRarity: Rarity) {
        self.remainingActivationsLock.wait()
        
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

        self.remainingActivationsLock.signal()
    }
}
