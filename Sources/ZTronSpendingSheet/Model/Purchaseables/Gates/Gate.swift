import Foundation

public final class Gate: PurchaseableWeaponDecorator, ObservableObject, @unchecked Sendable {
    private let name: String
    private let price: Double
    private let description: String
    private let assetsImageName: String
    private var categories: Set<PurchaseableCategory>
    private var availability: Int
    
    private let categoriesSemaphore = DispatchSemaphore(value: 1)
    private let availabilitySemaphore = DispatchSemaphore(value: 1)
    private let amountSemaphore = DispatchSemaphore(value: 1)
    
    
    public var coupon: (any Coupon)? = nil
    
    public let id: String
    
    public init(name: String, price: Double, description: String, assetsImageName: String, categories: Set<PurchaseableCategory>) {
        self.name = name
        self.price = price
        self.id = name
        self.assetsImageName = assetsImageName
        self.description = description
        self.availability = 1
        
        self.categories = .init([.door])
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
        if let coupon = self.coupon {
            return self.price * (1 - coupon.getPriceOffPercentage())
        } else {
            return self.price
        }
    }
    
    public func makeDeepCopy() -> Self {
        // Constructor makes a defensive copy of categories anyway
        self.categoriesSemaphore.wait()
        self.availabilitySemaphore.wait()
        self.amountSemaphore.wait()
        
        defer {
            self.amountSemaphore.signal()
            self.availabilitySemaphore.signal()
            self.categoriesSemaphore.signal()
        }
        
        let deepCopy = Self(name: self.name, price: self.price, description: self.description, assetsImageName: self.assetsImageName, categories: self.categories)
        deepCopy.coupon = self.coupon?.makeDeepCopy()
        
        return deepCopy
    }
    
    public func getAvailability() -> Int {
        self.availabilitySemaphore.wait()
        
        defer {
            self.availabilitySemaphore.signal()
        }
        
        return self.availability
    }
    
    public func decrementAvailability(amount: Int = 1) {
        assert(amount >= 0)
        self.availabilitySemaphore.wait()
        
        defer {
            self.availabilitySemaphore.signal()
        }
        
        self.availability = max(self.availability - amount, 0)
    }
    
    public func increaseAvailability(amount: Int = 1) {
        assert(amount >= 0)
        
        self.availabilitySemaphore.wait()
        
        defer {
            self.availabilitySemaphore.signal()
        }
        
        self.availability += amount
    }
    
    
    public func getCompatibleCoupons() -> [CouponType] {
        return [.skeletonKey]
    }
    
    public func applyCouponIfCompatible(_ coupon: any Coupon) -> Bool {
        if self.getCompatibleCoupons().contains(coupon.type) {
            self.coupon = coupon
            coupon.use()
            return true
        } else {
            return false
        }
    }

    @discardableResult public func removeCoupon(_ coupon: CouponType) -> Bool {
        guard let currentCoupon = self.coupon else { return false }
        
        if currentCoupon.type == coupon {
            self.coupon?.release()
            self.coupon = nil
            return true
        } else {
            return false
        }
    }
    
    public func getAmount() -> Int { return 1 }
    public func increaseAmount() { }
    public func decreaseAmount() { }

}
