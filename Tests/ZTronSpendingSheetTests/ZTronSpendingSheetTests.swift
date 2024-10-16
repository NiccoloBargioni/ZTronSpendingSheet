import Testing
@testable import ZTronSpendingSheet

@Test func packAPunchedWeapon() async throws {
    let weapon = Weapon(name: "MP-40", price: 750)
    let packAPunchedWeapon = WeaponPackAPunchDecorator(decoratedWeapon: weapon)
    
    let myWeapon: any Purchaseable = packAPunchedWeapon
    
    #expect(myWeapon.getPrice() == 1750.0)
    #expect(myWeapon.id == "MP-40 w/ pack-a-punch")
    
    // MARK: Test deep copy
    #expect(weapon !== weapon.makeDeepCopy())
    #expect(((myWeapon as! WeaponPackAPunchDecorator).getDecoratedWeapon() as! Weapon) !== weapon)
}

@Test func spendingModel() async throws {
    let spendingModel = SpendingModel(validationStrategy: TwoPlayersValidatorStrategy())
    
    spendingModel.appendPurchase(
        Weapon(name: "MP-40", price: 750)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "PPSH", price: 750)
    )
    
    spendingModel.appendPurchase(
        Weapon(name: "STG-40", price: 750)
    )
    
    // MARK: - Testing removal
    #expect(spendingModel.removePurchaseById("1911") == nil)
    #expect(spendingModel.removePurchaseById("MP-40") != nil)
    #expect(spendingModel.removePurchaseById("MP-40") == nil)
    
    // MARK: - Testing addition
    #expect(spendingModel.appendPurchase(Weapon(name: "MP-40", price: 750)) == true)
    #expect(spendingModel.appendPurchase(Weapon(name: "MP-40", price: 750)) == false)

    // MARK: - Testing replacement
    #expect(spendingModel.replacePurchase("STG-40", withPurchase: WeaponPackAPunchDecorator(decoratedWeapon: Weapon(name: "STG-40", price: 750))) != nil) // Can do, STG exists
    #expect(spendingModel.replacePurchase("STG-40", withPurchase: WeaponPackAPunchDecorator(decoratedWeapon: Weapon(name: "STG-40", price: 750))) == nil) // Can't do, STG was replaced with pap
    #expect(spendingModel.replacePurchase("1911", withPurchase: WeaponPackAPunchDecorator(decoratedWeapon: Weapon(name: "1911", price: 750))) == nil) // Can't do, 1911 was removed
    
    #expect(spendingModel.validate() == false)
}
