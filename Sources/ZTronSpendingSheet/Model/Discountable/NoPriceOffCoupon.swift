import Foundation


internal final class NoPriceOffCoupon: Discountable {
    
    internal init() {  }
    
    internal func makeDeepCopy() -> Self {
        return .init()
    }    
}
