import Foundation


public final class NoPriceOffCoupon: Discountable {
    
    public init() {  }
    
    public func makeDeepCopy() -> Self {
        return .init()
    }    
}
