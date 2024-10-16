import Foundation

internal final class SpendingModel: @unchecked Sendable {
    
    private var purchases: [any Purchaseable] = .init()
    private var validationStrategy: any SpendingValidatorStrategy
    
    private let purchasesLock: DispatchSemaphore = .init(value: 1)
    private let validatorLock: DispatchSemaphore = .init(value: 1)
    
    init(validationStrategy: any SpendingValidatorStrategy) {
        self.validationStrategy = validationStrategy
    }
    

    internal func validate() -> Bool {
        self.validatorLock.wait()
        // private array of immutable objects likely doesn't need deepcopy
        let isValid = self.validationStrategy.validate(purchases: self.purchases)
        
        self.validatorLock.signal()
        
        return isValid
    }
    
    /// Adds another purchase to the lists of purchased items. If another purchase withe the same ID existed, the application aborts.
    /// - Parameter thePurchase: The new purchase to add
    /// - Complexity: O(`purchases.count`) to test if another purchase already existed.
    @discardableResult internal func appendPurchase(_ thePurchase: any Purchaseable) -> Bool {
        guard (self.findPurchaseById(thePurchase.id) == nil) else { return false }
        
        self.purchasesLock.wait()
        self.purchases.append(thePurchase.makeDeepCopy())
        self.purchasesLock.signal()
        
        return true
    }
    
    
    /// - Note: This method doesn't return a deep copy of the found element. It's responsibility of the client to deepCopy it if needed.
    private final func findPurchaseById(_ id: String) -> (any Purchaseable)? {
        self.purchasesLock.wait()
        let elementToRemove = self.purchases.first { thePurchaseable in
            return thePurchaseable.id == id
        }
        self.purchasesLock.signal()
        
        guard let elementToRemove = elementToRemove else { return nil }
        return elementToRemove
    }
    
    
    private final func findPurchaseIndexById(_ id: String) -> Int? {
        self.purchasesLock.wait()
        let elementIndex: Int? = self.purchases.firstIndex { thePurchaseable in
            return thePurchaseable.id == id
        }
        self.purchasesLock.signal()
        
        return elementIndex
    }
    
    
    /// Removes the element with the specified `id` if any is contained in the collection.
    /// If an element was removed successfully, a deep copy of such element is returned.
    /// If no such element existed in the collection, this method returns nil.
    ///
    ///  - Parameter id: The id to search in the purchases collection.
    ///  - Returns: a deepcopy of the removed element, if any, `nil` otherwise.
    ///
    ///  - Complexity: O(`purchases.count`) to find the element to remove.
    @discardableResult internal func removePurchaseById(_ id: String) -> (any Purchaseable)? {
        
        guard let indexToRemove = self.findPurchaseIndexById(id) else { return nil }
        let purchaseClone = self.purchases[indexToRemove].makeDeepCopy()
                
        self.purchasesLock.wait()
        self.purchases.remove(at: indexToRemove)
        self.purchasesLock.signal()

        return purchaseClone
    }
    
    
    /// Replaces purchase with a specified id with another purchase, if an element with the specified id exists. No-op otherwise.
    /// - Parameter id: The id of the parameter to replace
    /// - Parameter withPurchase: The purchaseable item to replace the existing one with.
    /// - Returns: A deepcopy of the replaced item, if any item was replaced. `nil` otherwise.
    ///
    /// - Complexity: O(purchases.count) to find the element to replace.
    /// - Note: Use this method mainly to dynamically attach or detach (i.e. decorate) responsibilities to a purchase.
    @discardableResult internal func replacePurchase(_ id: String, withPurchase: any Purchaseable) -> (any Purchaseable)? {
        guard let indexOfElementToReplace = self.findPurchaseIndexById(id) else { return nil }
        
        self.purchasesLock.wait()
        
        let removedElement = self.purchases[indexOfElementToReplace].makeDeepCopy()
        self.purchases[indexOfElementToReplace] = withPurchase.makeDeepCopy()
        
        self.purchasesLock.signal()
        
        return removedElement
    }
    
    
    /// Replaces the current validation strategy with the specified one.
    /// - Parameter theStrategy: A validation strategy to use from the moment this method was called onwards.
    internal func setValidationStrategy(_ theStrategy: any SpendingValidatorStrategy) {
        self.validatorLock.wait()
        self.validationStrategy = theStrategy
        self.validatorLock.signal()
    }
}
