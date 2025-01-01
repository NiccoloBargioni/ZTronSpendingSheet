import Foundation

public final class SpendingModel: @unchecked Sendable {
    
    private var purchases: [Player: [any Purchaseable]] = [:]
    private var validationStrategy: any SpendingValidatorStrategy
    
    private let purchasesLock: DispatchSemaphore = .init(value: 1)
    private let validatorLock: DispatchSemaphore = .init(value: 1)
    
    init(validationStrategy: any SpendingValidatorStrategy) {
        self.validationStrategy = validationStrategy
    }
    

    public func validate() -> Bool {
        self.validatorLock.wait()
        // private array of immutable objects likely doesn't need deepcopy
        let isValid = self.validationStrategy.validate(purchases: self.purchases)
        
        self.validatorLock.signal()
        
        return isValid
    }
    
    /// Adds another purchase to the lists of purchased items for the player the purchase belongs to..
    /// - Parameter thePurchase: The new purchase to add.
    /// - Returns: True, if no purchase with the same name existed for `thePurchase.player`, `false` otherwise.
    /// - Complexity: O(`purchases.count`) to test if another purchase already existed.
    @discardableResult public func appendPurchase(_ thePurchase: any Purchaseable) -> Bool {
        guard let thePlayer = thePurchase.player else { return false }
        guard (self.findPurchaseById(thePurchase.id, for: thePlayer) == nil) else { return false }
        
        if self.purchases[thePlayer] == nil {
            self.purchases[thePlayer] = .init()
        }
        
        self.purchasesLock.wait()
        self.purchases[thePlayer]?.append(thePurchase)
        self.purchasesLock.signal()
        
        return true
    }
    
    
    /// - Note: This method doesn't return a deep copy of the found element. It's responsibility of the client to deepCopy it if needed.
    private final func findPurchaseById(_ id: String, for player: Player) -> (any Purchaseable)? {
        guard self.purchases[player] != nil else { return nil }
        
        self.purchasesLock.wait()
        
        let elementToRemove = self.purchases[player]?.first { thePurchaseable in
            return thePurchaseable.id == id
        }
        
        self.purchasesLock.signal()
        
        guard let elementToRemove = elementToRemove else { return nil }
        return elementToRemove
    }
    
    
    private final func findPurchaseIndexById(_ id: String, for player: Player) -> Int? {
        guard self.purchases[player] != nil else { return nil }
        
        self.purchasesLock.wait()
        
        let elementIndex: Int? = self.purchases[player]?.firstIndex { thePurchaseable in
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
    ///  - Parameter for: The player that made the purchase to remove.
    ///  - Returns: a deepcopy of the removed element, if any, `nil` otherwise.
    ///
    ///  - Complexity: O(`purchases[for].count`) to find the element to remove.
    @discardableResult public func removePurchaseById(_ id: String, for player: Player) -> (any Purchaseable)? {
        guard self.purchases[player] != nil else { return nil }
        
        guard let indexToRemove = self.findPurchaseIndexById(id, for: player) else { return nil }
        let purchaseClone = self.purchases[player]?[indexToRemove].makeDeepCopy()
                
        self.purchasesLock.wait()
        self.purchases[player]?.remove(at: indexToRemove)
        self.purchasesLock.signal()

        return purchaseClone
    }
    
    
    /// Replaces purchase with a specified id with another purchase, if an element with the specified id exists. No-op otherwise.
    /// This implementation looks for the purchase with the specified id in the collection for `withPurchase.player`.
    ///
    /// - Parameter id: The id of the parameter to replace
    /// - Parameter withPurchase: The purchaseable item to replace the existing one with.
    /// - Returns: A deepcopy of the replaced item, if any item was replaced. `nil` otherwise.
    ///
    /// - Complexity: O(`purchases[withPurchase.player].count`) to find the element to replace.
    /// - Note: Use this method mainly to dynamically attach or detach (i.e. decorate) responsibilities to a purchase.
    @discardableResult public func replacePurchase(_ id: String, withPurchase: any Purchaseable) -> (any Purchaseable)? {
        guard let thePlayer = withPurchase.player else { return nil }
        guard let indexOfElementToReplace = self.findPurchaseIndexById(id, for: thePlayer) else { return nil }
        
        self.purchasesLock.wait()
        
        let removedElement = self.purchases[thePlayer]?[indexOfElementToReplace].makeDeepCopy()
        self.purchases[thePlayer]?[indexOfElementToReplace] = withPurchase.makeDeepCopy()
        
        self.purchasesLock.signal()
        
        return removedElement
    }
    
    
    /// Replaces the current validation strategy with the specified one.
    /// - Parameter theStrategy: A validation strategy to use from the moment this method was called onwards.
    public func setValidationStrategy(_ theStrategy: any SpendingValidatorStrategy) {
        self.validatorLock.wait()
        self.validationStrategy = theStrategy
        self.validatorLock.signal()
    }
}
