import Foundation

public protocol Purchaseable: Identifiable, Sendable, Cloneable, Discountable {
    var id: String { get }
    var player: Player { get }
    func getName() -> String
    func getDescription() -> String
    func getPrice() -> Double
}

public enum PurchaseableCategory: String, CaseIterable {
    case smg = "SMG"
    case lmg = "LMG"
    case pistol = "PISTOL"
    case sniper = "SNIPER"
    case weapon = "WEAPON"
    case shotgun = "SHOTGUN"
    case door = "DOOR"
    case mandatory = "MANDATORY"
}
