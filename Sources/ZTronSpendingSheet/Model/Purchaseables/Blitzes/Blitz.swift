import Foundation

internal final class Blitz: Purchaseable, ObservableObject, @unchecked Sendable {
    private let name: String
    private let price: Double
    private let description: String
    private let assetsImageName: String
    @Published private var amount: Int
    private var categories: Set<PurchaseableCategory>
    private let categoriesSemaphore = DispatchSemaphore(value: 1)
    private let amountSemaphore = DispatchSemaphore(value: 1)
    
    internal let id: String
    internal var coupon: (any Coupon)? = nil 
    
    internal init(name: String, price: Double, description: String, assetsImageName: String, amount: Int = 0) {
        self.name = name
        self.price = price
        self.id = name
        self.assetsImageName = assetsImageName
        self.description = description
        self.amount = amount
        
        self.categories = .init()
        categories.insert(.perks)
    }
    
    internal func getName() -> String {
        return self.name
    }
    
    internal func getDescription() -> String {
        return self.description
    }
    
    internal func getAssetsImage() -> String {
        return self.assetsImageName
    }
    
    internal func getCategories() -> Set<PurchaseableCategory> {
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
    
    internal func getPrice() -> Double {
        if let coupon = self.coupon {
            return self.price * (1 - coupon.getPriceOffPercentage())
        } else {
            return self.price
        }
    }
    
    internal func makeDeepCopy() -> Self {
        // Constructor makes a defensive copy of categories anyway
        self.categoriesSemaphore.wait()
        self.amountSemaphore.wait()
        
        defer {
            self.amountSemaphore.signal()
            self.categoriesSemaphore.signal()
        }
        
        return Self(name: self.name, price: self.price, description: self.description, assetsImageName: self.assetsImageName, amount: self.amount)
    }
    
    internal func getAvailability() -> Int {
        return Int.max / 2
    }
    
    internal func getAmount() -> Int {
        self.amountSemaphore.wait()
        
        defer {
            self.amountSemaphore.signal()
        }
        
        return self.amount
    }
    
    internal func decreaseAmount() {
        self.amountSemaphore.wait()
        
        self.amount = max(0, self.amount - 1)
        
        self.amountSemaphore.signal()
    }
    
    internal func increaseAmount() {
        self.amountSemaphore.wait()
        
        self.amount += 1
        
        self.amountSemaphore.signal()

    }
    
    internal func getCompatibleCoupons() -> [CouponType] {
        return [.refundCoupon, .blitzMachineCoupon]
    }

    internal func applyCouponIfCompatible(_ coupon: any Coupon) -> Bool {
        if self.getCompatibleCoupons().contains(coupon.type) {
            self.coupon = coupon
            coupon.use()
            return true
        } else {
            return false
        }
    }
    
    @discardableResult internal func removeCoupon(_ coupon: CouponType) -> Bool {
        guard let currentCoupon = self.coupon else { return false }
        
        if currentCoupon.type == coupon {
            self.coupon = nil
            return true
        } else {
            return false
        }
    }

}
