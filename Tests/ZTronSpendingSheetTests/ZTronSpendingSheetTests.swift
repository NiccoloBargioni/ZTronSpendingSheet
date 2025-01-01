import Testing
@testable import ZTronSpendingSheet

@Test func packAPunchedWeapon() async throws {
    let weapon = Weapon(name: "MP-40", price: 750, player: .player1)
    let packAPunchedWeapon = WeaponPackAPunch(decoratedWeapon: weapon)
    
    let myWeapon: any Purchaseable = packAPunchedWeapon
    
    #expect(myWeapon.getPrice() == 1750.0)
    #expect(myWeapon.id == "MP-40 w/ pack-a-punch")
    
    // MARK: Test deep copy
    #expect(weapon !== weapon.makeDeepCopy())
    #expect(((myWeapon as! WeaponPackAPunch).getDecoratedWeapon() as! Weapon) !== weapon)
}

@Test func spendingModel() async throws {
    let spendingModel = SpendingModel(validationStrategy: TwoPlayersValidatorStrategy())
    
    spendingModel.appendPurchase(
        Weapon(name: "MP-40", price: 750, player: .player1)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "PPSH", price: 750, player: .player1)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "STG-40", price: 750, player: .player1)
    )
    
    // MARK: - Testing removal
    #expect(spendingModel.removePurchaseById("1911", for: .player1) == nil)
    #expect(spendingModel.removePurchaseById("MP-40", for: .player1) != nil)
    #expect(spendingModel.removePurchaseById("MP-40", for: .player1) == nil)
    
    // MARK: - Testing addition
    #expect(spendingModel.appendPurchase(Weapon(name: "MP-40", price: 750, player: .player1)) == true)
    #expect(spendingModel.appendPurchase(Weapon(name: "MP-40", price: 750, player: .player1)) == false)

    // MARK: - Testing replacement
    #expect(
        spendingModel.replacePurchase(
            "STG-40",
            withPurchase: WeaponPackAPunch(
                decoratedWeapon:
                    Weapon(
                        name: "STG-40",
                        price: 750,
                        player: .player1
                    )
            )
        ) != nil
    ) // Can do, STG exists
    
    
    #expect(
        spendingModel.replacePurchase(
            "STG-40", withPurchase: WeaponPackAPunch(
                decoratedWeapon:
                    Weapon(
                        name: "STG-40",
                        price: 750,
                        player: .player1
                    )
            )
        ) == nil) // Can't do, STG was replaced with pap
    
    
    #expect(
        spendingModel.replacePurchase(
            "1911", withPurchase: WeaponPackAPunch(
                decoratedWeapon:
                    Weapon(
                        name: "1911",
                        price: 750,
                        player: .player1
                    )
            )
        ) == nil) // Can't do, 1911 was removed
    
    #expect(spendingModel.validate() == false)
}


@Test func spendingModelWithPlayers() async throws {
    let spendingModel = SpendingModel(validationStrategy: TwoPlayersValidatorStrategy())
    
    spendingModel.appendPurchase(
        Weapon(name: "M1A1 Carabine", price: 0, player: .player1)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "1911", price: 0, player: .player1)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "M1A1 Carabine", price: 0, player: .player2)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "STG-40", price: 0, player: .player2)
    )
    
    
    #expect(spendingModel.appendPurchase(
        Weapon(name: "STG-40", price: 0, player: .player1)
    ) != nil)
    
    
    #expect(spendingModel.appendPurchase(
        Weapon(name: "STG-40", price: 0, player: .player2)
    ) == false)
    
    #expect(spendingModel.removePurchaseById("M1A1 Carabine", for: .player1) != nil)
    #expect(spendingModel.removePurchaseById("M1A1 Carabine", for: .player2) != nil)
    #expect(spendingModel.removePurchaseById("M1A1 Carabine", for: .player2) == nil)

    
    #expect(
        spendingModel.replacePurchase("STG-40", withPurchase: WeaponPackAPunch(decoratedWeapon:
            Weapon(name: "STG-40", price: 0, player: .player1),
            coupon: DiscountCoupon()
       )) != nil
    )
    
    #expect(
        spendingModel.removePurchaseById("STG-40", for: .player1) == nil
    )
    
    #expect(
        spendingModel.removePurchaseById("STG-40", for: .player2) != nil
    )
    
    let weaponWithCoupon = WeaponPackAPunch(decoratedWeapon:
            Weapon(name: "STG-40", price: 750, player: .player1),
            coupon: DiscountCoupon()
        )
    
    print(weaponWithCoupon.getPrice())
}
