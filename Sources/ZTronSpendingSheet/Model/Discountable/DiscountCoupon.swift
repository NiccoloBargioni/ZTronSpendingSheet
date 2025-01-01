import Foundation

internal final class DiscountCoupon: Discountable {
    
    internal init() {  }
    
    internal func makeDeepCopy() -> Self {
        return .init()
    }
    
    internal func getPriceOffPercentage() -> Double {
        return 0.25
    }
    
}
