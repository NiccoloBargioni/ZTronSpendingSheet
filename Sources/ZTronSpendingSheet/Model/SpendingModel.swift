import Foundation

public final class SpendingModel: @unchecked Sendable, ObservableObject {
    @Published private var coupon: [Player: [any Coupon]] = [:]
    
    @Published private var purchases: [Player: [any Purchaseable]] = [:]
    private var validationStrategy: any SpendingValidatorStrategy
    
    private let purchasesLock: DispatchSemaphore = .init(value: 1)
    private let validatorLock: DispatchSemaphore = .init(value: 1)
    
    public init(validationStrategy: any SpendingValidatorStrategy) {
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
    /// Decreases by 1 the availability of the specified purchase.
    ///
    /// - Parameter thePurchase: The new purchase to add.
    /// - Returns: True, if no purchase with the same name existed for `thePurchase.player`, `false` otherwise.
    /// - Complexity: O(`purchases.count`) to test if another purchase already existed.
    @discardableResult public func appendPurchase(_ thePurchase: any Purchaseable, to player: Player) -> Bool {
        guard (self.findPurchaseById(thePurchase.id, for: player) == nil) else { return false }
        guard thePurchase.getAvailability() > 0 else { return false }
        
        if self.purchases[player] == nil {
            self.purchases[player] = .init()
        }
        
        if let existingPurchase = purchases[player]?.first(where: { purchaseable in
            return purchaseable.id == thePurchase.id
        }) {
            existingPurchase.increaseAmount()
            existingPurchase.decrementAvailability(amount: 1)
        } else {
            if thePurchase.getAvailability() > 0 {
                self.purchasesLock.wait()
                self.purchases[player]?.append(thePurchase)
                self.purchasesLock.signal()
                
                thePurchase.decrementAvailability(amount: 1)
                thePurchase.increaseAmount()
            }
        }
        
        return true
    }
    
    
    /// - Note: This method doesn't return a deep copy of the found element. It's responsibility of the client to deepCopy it if needed.
    public final func findPurchaseById(_ id: String, for player: Player) -> (any Purchaseable)? {
        guard self.purchases[player] != nil else { return nil }
        
        self.purchasesLock.wait()
        
        let elementToRemove = self.purchases[player]?.first { thePurchaseable in
            return thePurchaseable.id == id
        }
        
        self.purchasesLock.signal()
        
        guard let elementToRemove = elementToRemove else { return nil }
        return elementToRemove
    }
    
    
    /// - Note: This method doesn't return a deep copy of the found element. It's responsibility of the client to deepCopy it if needed.
    private final func findPurchaseById(_ id: String) -> (any Purchaseable)? {
        return self.findPurchaseById(id, for: .player1) ?? self.findPurchaseById(id, for: .player2) ?? self.findPurchaseById(id, for: .player3) ?? self.findPurchaseById(id, for: .player3) ?? self.findPurchaseById(id, for: .player4)
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
    
    private final func findPurchaseIndexById(_ id: String) -> PurchaseIndex? {
        if let purchaseInPlayer1 = self.findPurchaseIndexById(id, for: .player1) {
            return PurchaseIndex(index: purchaseInPlayer1, player: .player1)
        } else {
            if let purchaseInPlayer2 = self.findPurchaseIndexById(id, for: .player2) {
                return PurchaseIndex(index: purchaseInPlayer2, player: .player2)
            } else {
                if let purchaseInPlayer3 = self.findPurchaseIndexById(id, for: .player3) {
                    return PurchaseIndex(index: purchaseInPlayer3, player: .player3)
                } else {
                    if let purchaseInPlayer4 = self.findPurchaseIndexById(id, for: .player4) {
                        return PurchaseIndex(index: purchaseInPlayer4, player: .player4)
                    } else {
                        return nil
                    }
                }
            }
        }
    }
    
    
    
    /// Removes the element with the specified `id` if any is contained in the collection.
    /// If an element was removed successfully, a deep copy of such element is returned.
    /// If no such element existed in the collection, this method returns nil.
    /// This method increases by 1 the availability of the removed purchase.
    ///
    ///  - Parameter id: The id to search in the purchases collection.
    ///  - Parameter for: The player that made the purchase to remove.
    ///  - Returns: a deepcopy of the removed element, if any, `nil` otherwise.
    ///
    ///  - Complexity: O(`purchases[for].count`) to find the element to remove.
    @discardableResult public func removePurchaseById(_ id: String, for player: Player) -> (any Purchaseable)? {
        guard self.purchases[player] != nil else { return nil }
        
        guard let indexToRemove = self.findPurchaseIndexById(id, for: player) else { return nil }
        
        if let thePurchaseToRemove = self.purchases[player]?[indexToRemove] {
            thePurchaseToRemove.increaseAvailability(amount: thePurchaseToRemove.getAmount())
        }
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
        guard let thePlayer = self.findPurchaseIndexById(id)?.getPlayer() else { return nil }
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
    
    
    @discardableResult public func movePurchase(id: String, to player: Player) -> Bool {
        guard let thePurchaseIndex = self.findPurchaseIndexById(id) else { return false }
        guard let thePurchase = self.purchases[thePurchaseIndex.getPlayer()]?[thePurchaseIndex.getIndex()] else { return false }
        
        
        if thePurchaseIndex.getPlayer() != player {
            self.purchases[thePurchaseIndex.getPlayer()]?.removeAll { purchaseable in
                return purchaseable.id == thePurchase.id
            }
        }
        
        if self.purchases[player] == nil {
            self.purchases[player] = .init()
        }
        
        self.purchases[player]?.append(thePurchase)
        
        return true
    }
    
    
    public func getPurchasesForPlayer(_ player: Player) -> [any Purchaseable]? {
        guard let purchases = self.purchases[player] else { return nil }
        
        return purchases.map { thePurchase in
            return thePurchase.makeDeepCopy()
        }
    }
    
    @discardableResult public func increaseAmountOfPurchaseById(_ id: String, for player: Player) -> Bool {
        guard let thePurchase = self.findPurchaseById(id, for: player) else { return false }
        
        thePurchase.increaseAmount()
        thePurchase.decrementAvailability(amount: 1)
        
        return true
    }
    
    
    @discardableResult public func decreaseAmountOfPurchaseById(_ id: String, for player: Player) -> Bool {
        guard let thePurchase = self.findPurchaseById(id, for: player) else { return false }
        
        thePurchase.decreaseAmount()
        thePurchase.increaseAvailability(amount: 1)
        
        return true
    }
    
    fileprivate struct PurchaseIndex: Hashable {
        private let index: Int
        private let player: Player
        
        fileprivate init(index: Int, player: Player) {
            self.index = index
            self.player = player
        }
        
        fileprivate func getIndex() -> Int {
            return self.index
        }
        
        fileprivate func getPlayer() -> Player {
            return self.player
        }
    }
    
    
    // MARK: - HANDLING CONSUMABLES:
    
    private final func makeCouponForType(_ type: CouponType, withRarity: Rarity = .common) -> any Coupon {
        switch type {
        case .skeletonKey:
            return SkeletonKey(rarity: withRarity)
        case .refundCoupon:
            return RefundCoupon(rarity: withRarity)
        case .mysteryBoxKey:
            return MysteryBoxKey(rarity: withRarity)
        case .blitzMachineCoupon:
            return BlitzMachineKey(rarity: withRarity)
        }
    }
    
    @discardableResult public final func addConsumable(_ theConsumableType: CouponType, rarity: Rarity = .common, player: Player) -> Bool {
        if let couponsForPlyer = self.coupon[player] {
            // Zero or more active coupons but already init
            guard couponsForPlyer.count < 2 else { return false }
            
            if !couponsForPlyer.contains(where: { theCoupon in
                return theCoupon.type == theConsumableType
            }) {
                self.coupon[player]?.append(makeCouponForType(theConsumableType, withRarity: rarity))
            } else {
                self.removeConsumableFromAllPurchasesForPlayer(theConsumableType, player: player)
                self.coupon[player]?.removeAll { coupon in
                    return coupon.type == theConsumableType
                }
            }
        } else {
            // First time adding something to this player
            self.coupon[player] = [makeCouponForType(theConsumableType, withRarity: rarity)]
        }
        
        return true
    }
    
    @discardableResult private final func removeConsumableFromAllPurchasesForPlayer(_ consumableType: CouponType, player: Player) -> Bool {
        if let couponsForPlyer = self.coupon[player] {
            // Zero or more active coupons but already init
            guard couponsForPlyer.count > 0 else { return false }
            
            if let theCouponToRemove = couponsForPlyer.first(where: { theCoupon in
                return theCoupon.type == consumableType
            })  {
                self.purchases[player]?.forEach { purchase in
                    purchase.removeCoupon(consumableType)
                    theCouponToRemove.release()
                }
            }
            
            return true
        } else {
            return false
        }
    }
    
    @discardableResult public final func removeCouponFromAllPurchases(_ couponType: CouponType) -> Bool {
        var removedItemsCount: Int = 0
        
        Player.allCases.forEach { player in
            if let purchasesForThisPlayer = self.purchases[player] {
                purchasesForThisPlayer.forEach { purchase in
                    if purchase.removeCoupon(couponType) {
                        removedItemsCount += 1
                    }
                }
            }
        }
        
        return removedItemsCount > 0
    }
    
    @discardableResult public final func useCoupon(_ couponType: CouponType, purchaseID: String, for player: Player) -> Bool {
        guard let thePurchase = self.findPurchaseById(purchaseID) else { return false }
        guard let activeCouponsForPlayer = self.coupon[player] else { return false }
        guard let activeCoupon = activeCouponsForPlayer.first(where: { coupon in
            return coupon.type == couponType
        }) else { return false }
        
        guard activeCoupon.remainingActivations > 0 else { return false }
        
        let couponActivationSuccessful = thePurchase.applyCouponIfCompatible(activeCoupon)
        self.objectWillChange.send()
        return couponActivationSuccessful
    }
    
    @discardableResult public final func releaseCoupon(_ couponType: CouponType, purchaseID: String, for player: Player) -> Bool {
        guard let thePurchase = self.findPurchaseById(purchaseID) else { return false }
        guard let activeCouponsForPlayer = self.coupon[player] else { return false }
        guard let activeCoupon = activeCouponsForPlayer.first(where: { coupon in
            return coupon.type == couponType
        }) else { return false }
        
        let didRemoveCoupon = thePurchase.removeCoupon(activeCoupon.type)
        
        self.objectWillChange.send()
        return didRemoveCoupon
    }
    
    
    @discardableResult public final func changeConsumableRarity(consumable: CouponType, to rarity: Rarity, for player: Player) -> Bool {
        guard let couponsForPlayer = self.coupon[player] else { return false }
        guard let theCoupon = couponsForPlayer.first(where: { coupon in
            coupon.type == consumable
        }) else {
            return false
        }
        
        theCoupon.changeRarity(to: rarity)
        
        self.objectWillChange.send()
        return true
    }
    
    
    /*
    // TODO: Release all usages
    public func removeConsumable(_ theConsumableType: CouponType, for player: Player) {
        if let couponsForPlayer = self.coupon[player] {
            if let releasedCount = self.purchases[player]?.count(where: { purchase in
                return purchase.coupon?.type == theConsumableType
            }) {
                couponsForPlayer.forEach { coupon in
                    if coupon.type == theConsumableType {
                        coupon.release()
                    }
                }
            }
        }
        
        self.coupon[player]?.removeAll { coupon in
            return coupon.type == theConsumableType
        }
    }
    */
    
    public func canReplaceConsumableRarity(consumable: CouponType, switchingToRarity: Rarity, for player: Player) -> Bool {
        guard let theCoupon = self.coupon[player]?.first(where: { coupon in
            coupon.type == consumable
        }) else {
            return true
        }
        
        // The number of times the coupon was activated is at least the same as the times the new coupon can be activated
        return theCoupon.activationsCount <= Rarity.rarityPriority[switchingToRarity]! + 1
    }
    
    
    public func getActiveConsumablesByPlayer(_ player: Player) -> [any Coupon]? {
        return self.coupon[player]?.map { someCoupon in
            return someCoupon.makeDeepCopy()
        }
    }
    
    public func isConsumableActiveForPlayer(_ consumable: CouponType, player: Player) -> Bool {
        guard let couponsForPlayer = self.coupon[player] else { return false }
        return couponsForPlayer.first { activeCoupon in
            return activeCoupon.type == consumable
        } != nil
    }
    
    public func getRemainingActivations(consumable: CouponType, player: Player) -> Int {
        guard let couponsForPlayer = self.coupon[player] else { return 0 }
        guard let theConsumable = couponsForPlayer.first(where: { activeCoupon in
            return activeCoupon.type == consumable
        }) else { return 0 }

        return theConsumable.remainingActivations
    }
    
    
    public func getTotalSpent(for player: Player) -> Double? {
        guard let purchasesForPlayer = self.purchases[player] else { return nil }
        
        return purchasesForPlayer.reduce(0.0) { partialResult, nextPurchase in
            return partialResult + nextPurchase.getPrice()
        }
    }
}
