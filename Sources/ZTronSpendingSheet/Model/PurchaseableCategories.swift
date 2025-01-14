import Foundation

public enum PurchaseableCategory: String, CaseIterable, Identifiable {
    public var id : String { UUID().uuidString }

    case mandatory = "MANDATORY"
    case perks = "PERKS"
    case smg = "SMG"
    case ar = "ASSAULT RIFLE"
    case pistol = "PISTOL"
    case sniper = "SNIPER"
    case weapon = "WEAPON"
    case shotgun = "SHOTGUN"
    case door = "DOOR"
    case misc = "MISCELLANEOUS"
}
