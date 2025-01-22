import Foundation

public enum Rarity: String, CaseIterable, Sendable, Identifiable {
    public var id: String { return UUID().uuidString }
    case common = "COMMON"
    case rare = "RARE"
    case legendary = "LEGENDARY"
    case epic = "EPIC"
    
    public static func <=(_ lhs: Rarity, _ rhs: Rarity) -> Bool {
        return Rarity.rarityPriority[lhs]! <= Rarity.rarityPriority[rhs]!
    }
    
    internal static var rarityPriority: [Rarity: Int] {
        return [
            .common: 0,
            .rare: 1,
            .legendary: 2,
            .epic: 3
        ]
    }
}
