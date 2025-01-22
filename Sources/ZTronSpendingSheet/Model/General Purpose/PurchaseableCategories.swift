import Foundation

internal enum PurchaseableCategory: String, CaseIterable, Identifiable {
    internal var id : String { UUID().uuidString }

    case mandatory = "MANDATORY"
    case perks = "PERKS"
    case smg = "SMG"
    case ar = "AR"
    case pistol = "PISTOL"
    case sniper = "SNIPER"
    case weapon = "WEAPON"
    case shotgun = "SHOTGUN"
    case door = "DOOR"
    case misc = "MISCELLANEOUS"
}
