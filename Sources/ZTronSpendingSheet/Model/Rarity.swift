import Foundation

public enum Rarity: String, CaseIterable, Sendable, Identifiable {
    public var id: String { return UUID().uuidString }
    case common = "COMMON"
    case rare = "RARE"
    case legendary = "LEGENDARY"
    case epic = "EPIC"
}
